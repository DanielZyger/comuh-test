require "rails_helper"

RSpec.describe "Api::V1::Sessions" do
  describe "POST /api/v1/sessions" do
    it "creates a new user and returns a token when the username is new" do
      expect {
        post "/api/v1/sessions", params: { username: "new_login" }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = response.parsed_body

      expect(body["user"]).to eq({ "id" => User.last.id, "username" => "new_login" })
      expect(body["token"]).to be_present
    end

    it "reuses the existing user when the username already exists" do
      existing = create(:user, username: "regular")

      expect {
        post "/api/v1/sessions", params: { username: "regular" }, as: :json
      }.not_to change(User, :count)

      expect(response.parsed_body["user"]["id"]).to eq(existing.id)
    end

    it "issues a token that authenticates subsequent requests" do
      post "/api/v1/sessions", params: { username: "authed" }, as: :json
      token = response.parsed_body["token"]
      message = create(:message)

      post "/api/v1/reactions",
        params: { message_id: message.id, reaction_type: "like" },
        headers: { "Authorization" => "Bearer #{token}" },
        as: :json

      expect(response).to have_http_status(:ok)
      expect(Reaction.sole.user.username).to eq("authed")
    end
  end
end
