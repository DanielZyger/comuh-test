require "rails_helper"

RSpec.describe "Api::V1::Messages" do
  describe "POST /api/v1/messages" do
    let(:community) { create(:community) }

    def post_message(params)
      post "/api/v1/messages", params: params, as: :json
    end

    it "creates a message and returns 201 with the expected shape" do
      post_message(
        username: "john_doe",
        community_id: community.id,
        content: "Conteúdo da mensagem",
        user_ip: "192.168.1.1"
      )

      expect(response).to have_http_status(:created)
      body = response.parsed_body

      expect(body).to include(
        "content" => "Conteúdo da mensagem",
        "community_id" => community.id,
        "parent_message_id" => nil
      )
      expect(body["user"]).to include("username" => "john_doe")
      expect(body["id"]).to be_present
      expect(body["created_at"]).to be_present
    end

    it "creates the user if the username does not exist yet" do
      expect {
        post_message(username: "brand_new", community_id: community.id, content: "oi", user_ip: "1.1.1.1")
      }.to change(User, :count).by(1)
    end

    it "reuses an existing user with the same username" do
      create(:user, username: "regular")

      expect {
        post_message(username: "regular", community_id: community.id, content: "oi", user_ip: "1.1.1.1")
      }.not_to change(User, :count)
    end

    it "computes the sentiment score from the content" do
      post_message(username: "u1", community_id: community.id, content: "excelente e ótimo", user_ip: "1.1.1.1")

      expect(response.parsed_body["ai_sentiment_score"]).to eq(1.0)
    end

    it "accepts a parent_message_id to create a reply" do
      parent = create(:message, community: community)

      post_message(
        username: "replier",
        community_id: community.id,
        content: "Concordo",
        user_ip: "1.1.1.1",
        parent_message_id: parent.id
      )

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["parent_message_id"]).to eq(parent.id)
    end

    it "returns 422 when content is missing" do
      post_message(username: "u1", community_id: community.id, user_ip: "1.1.1.1")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Content can't be blank")
    end

    it "returns 422 when the community does not exist" do
      post_message(username: "u1", community_id: 0, content: "oi", user_ip: "1.1.1.1")

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to include("Community must exist")
    end
  end

  describe "GET /api/v1/messages/:id" do
    it "returns the message with its replies" do
      message = create(:message)
      reply = create(:message, community: message.community, parent_message: message)

      get "/api/v1/messages/#{message.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body

      expect(body["message"]["id"]).to eq(message.id)
      expect(body["replies"].map { |r| r["id"] }).to contain_exactly(reply.id)
    end

    it "includes the reaction counts and reply count in the summary" do
      message = create(:message)
      create(:reaction, message: message, reaction_type: "like")

      get "/api/v1/messages/#{message.id}"

      body = response.parsed_body["message"]
      expect(body["reactions"]).to eq({ "like" => 1, "love" => 0, "insightful" => 0 })
      expect(body["reply_count"]).to eq(0)
    end

    it "returns 404 for a message that does not exist" do
      get "/api/v1/messages/0"

      expect(response).to have_http_status(:not_found)
    end
  end
end
