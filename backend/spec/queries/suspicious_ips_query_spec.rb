require "rails_helper"

RSpec.describe SuspiciousIpsQuery do
  describe "#call" do
    it "returns IPs used by at least min_users distinct users" do
      shared_ip = "10.0.0.1"
      create(:message, user: create(:user, username: "alice"), user_ip: shared_ip)
      create(:message, user: create(:user, username: "bob"), user_ip: shared_ip)
      create(:message, user: create(:user, username: "carol"), user_ip: shared_ip)

      results = described_class.new(min_users: 3).call

      expect(results.size).to eq(1)
      expect(results.first[:ip]).to eq(shared_ip)
      expect(results.first[:user_count]).to eq(3)
      expect(results.first[:usernames]).to match_array(%w[alice bob carol])
    end

    it "excludes IPs used by fewer distinct users than the threshold" do
      create(:message, user_ip: "10.0.0.2")

      results = described_class.new(min_users: 3).call

      expect(results).to be_empty
    end

    it "does not count the same user posting multiple times from the same IP more than once" do
      user = create(:user)
      create_list(:message, 3, user: user, user_ip: "10.0.0.3")

      results = described_class.new(min_users: 2).call

      expect(results).to be_empty
    end

    it "respects a custom min_users threshold" do
      shared_ip = "10.0.0.4"
      create(:message, user: create(:user), user_ip: shared_ip)
      create(:message, user: create(:user), user_ip: shared_ip)

      expect(described_class.new(min_users: 2).call.size).to eq(1)
      expect(described_class.new(min_users: 3).call).to be_empty
    end
  end
end
