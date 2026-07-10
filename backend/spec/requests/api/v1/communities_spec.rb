require "rails_helper"

RSpec.describe "Api::V1::Communities" do
  describe "GET /api/v1/communities" do
    it "lists communities with their message counts" do
      community = create(:community)
      create_list(:message, 2, community: community)
      create(:community)

      get "/api/v1/communities"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body["communities"]

      expect(body.size).to eq(2)
      listed = body.find { |c| c["id"] == community.id }
      expect(listed["message_count"]).to eq(2)
    end
  end

  describe "GET /api/v1/communities/:id" do
    it "returns the community and its last 50 top-level messages, newest first" do
      community = create(:community)
      older = create(:message, community: community, created_at: 2.days.ago)
      newer = create(:message, community: community, created_at: 1.hour.ago)
      create(:message, community: community, parent_message: newer)

      get "/api/v1/communities/#{community.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body

      expect(body["community"]).to include("id" => community.id, "name" => community.name)
      expect(body["messages"].map { |m| m["id"] }).to eq([ newer.id, older.id ])
    end

    it "returns 404 for a community that does not exist" do
      get "/api/v1/communities/0"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/communities/:id/messages/top" do
    it "ranks messages by engagement score" do
      community = create(:community)
      quiet = create(:message, community: community)
      popular = create(:message, community: community)
      create(:reaction, message: popular, reaction_type: "like")
      create(:reaction, message: popular, reaction_type: "love")

      get "/api/v1/communities/#{community.id}/messages/top"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body["messages"]

      expect(body.first["id"]).to eq(popular.id)
      expect(body.first["engagement_score"]).to eq(3.0)
      expect(body.map { |m| m["id"] }).to include(quiet.id)
    end

    it "defaults the limit to 10 and clamps values above 50" do
      community = create(:community)

      get "/api/v1/communities/#{community.id}/messages/top", params: { limit: 999 }

      expect(response).to have_http_status(:ok)
    end

    it "returns 404 for a community that does not exist" do
      get "/api/v1/communities/0/messages/top"

      expect(response).to have_http_status(:not_found)
    end
  end
end
