require "rails_helper"

RSpec.describe "Api::V1::Reactions" do
  let(:message) { create(:message) }
  let(:user) { create(:user) }

  def auth_headers(for_user)
    { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: for_user.id)}" }
  end

  describe "POST /api/v1/reactions" do
    it "creates a reaction using the user_id from the body when unauthenticated" do
      post "/api/v1/reactions",
        params: { message_id: message.id, user_id: user.id, reaction_type: "like" },
        as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["reactions"]).to eq({ "like" => 1, "love" => 0, "insightful" => 0 })
    end

    it "creates a reaction using the authenticated current_user, ignoring a missing user_id" do
      post "/api/v1/reactions",
        params: { message_id: message.id, reaction_type: "love" },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(Reaction.sole.user).to eq(user)
    end

    it "falls back to the body user_id when the token is invalid" do
      post "/api/v1/reactions",
        params: { message_id: message.id, user_id: user.id, reaction_type: "like" },
        headers: { "Authorization" => "Bearer not-a-real-token" },
        as: :json

      expect(response).to have_http_status(:ok)
      expect(Reaction.sole.user).to eq(user)
    end

    it "returns 422 when the same user reacts twice with the same type" do
      create(:reaction, message: message, user: user, reaction_type: "like")

      post "/api/v1/reactions",
        params: { message_id: message.id, user_id: user.id, reaction_type: "like" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "returns 409 when the database constraint catches a race the validation missed" do
      # Simula duas requisições passando pela validação de unicidade ao mesmo
      # tempo: a validação não pega (registro ainda não existe), mas o INSERT
      # colide com a constraint UNIQUE do Postgres.
      allow_any_instance_of(Reaction).to receive(:save!).and_raise(
        ActiveRecord::RecordNotUnique, "duplicate key value violates unique constraint"
      )

      post "/api/v1/reactions",
        params: { message_id: message.id, user_id: user.id, reaction_type: "like" },
        as: :json

      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body["error"]).to eq("Você já reagiu com esse tipo de reação nesta mensagem.")
    end

    it "returns 422 for an invalid reaction_type" do
      post "/api/v1/reactions",
        params: { message_id: message.id, user_id: user.id, reaction_type: "dislike" },
        as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 400 when message_id is missing" do
      post "/api/v1/reactions", params: { user_id: user.id, reaction_type: "like" }, as: :json

      expect(response).to have_http_status(:bad_request)
    end

    it "returns 404 for a message that does not exist" do
      post "/api/v1/reactions", params: { message_id: 0, user_id: user.id, reaction_type: "like" }, as: :json

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for a user that does not exist" do
      post "/api/v1/reactions", params: { message_id: message.id, user_id: 0, reaction_type: "like" }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/reactions" do
    it "removes an existing reaction and returns the updated counts" do
      create(:reaction, message: message, user: user, reaction_type: "like")

      delete "/api/v1/reactions", params: { message_id: message.id, reaction_type: "like" }, headers: auth_headers(user)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["reactions"]).to eq({ "like" => 0, "love" => 0, "insightful" => 0 })
      expect(Reaction.count).to eq(0)
    end

    it "allows reacting again after removing the reaction" do
      create(:reaction, message: message, user: user, reaction_type: "like")
      delete "/api/v1/reactions", params: { message_id: message.id, reaction_type: "like" }, headers: auth_headers(user)

      post "/api/v1/reactions",
        params: { message_id: message.id, reaction_type: "like" },
        headers: auth_headers(user),
        as: :json

      expect(response).to have_http_status(:ok)
      expect(Reaction.count).to eq(1)
    end

    it "returns 404 when the reaction does not exist" do
      delete "/api/v1/reactions", params: { message_id: message.id, reaction_type: "like" }, headers: auth_headers(user)

      expect(response).to have_http_status(:not_found)
    end
  end
end
