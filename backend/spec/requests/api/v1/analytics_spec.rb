require "rails_helper"

RSpec.describe "Api::V1::Analytics" do
  describe "GET /api/v1/analytics/suspicious_ips" do
    it "returns IPs shared by at least the default of 3 distinct users" do
      shared_ip = "10.0.0.1"
      create(:message, user: create(:user, username: "alice"), user_ip: shared_ip)
      create(:message, user: create(:user, username: "bob"), user_ip: shared_ip)
      create(:message, user: create(:user, username: "carol"), user_ip: shared_ip)
      create(:message, user_ip: "10.0.0.9")

      get "/api/v1/analytics/suspicious_ips"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body["suspicious_ips"]

      expect(body.size).to eq(1)
      expect(body.first["ip"]).to eq(shared_ip)
      expect(body.first["user_count"]).to eq(3)
      expect(body.first["usernames"]).to match_array(%w[alice bob carol])
    end

    it "respects a custom min_users query param" do
      shared_ip = "10.0.0.2"
      create(:message, user: create(:user), user_ip: shared_ip)
      create(:message, user: create(:user), user_ip: shared_ip)

      get "/api/v1/analytics/suspicious_ips", params: { min_users: 2 }

      expect(response.parsed_body["suspicious_ips"].size).to eq(1)
    end
  end
end
