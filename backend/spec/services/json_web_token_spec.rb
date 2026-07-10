require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode / .decode" do
    it "round-trips the payload" do
      token = described_class.encode(user_id: 42)

      expect(described_class.decode(token)[:user_id]).to eq(42)
    end

    it "returns nil for a tampered token" do
      token = described_class.encode(user_id: 42)
      tampered = "#{token}garbage"

      expect(described_class.decode(tampered)).to be_nil
    end

    it "returns nil for an expired token" do
      token = described_class.encode(user_id: 42, expires_in: -1.hour)

      expect(described_class.decode(token)).to be_nil
    end

    it "defaults to a 24 hour expiration" do
      token = described_class.encode(user_id: 42)
      payload = described_class.decode(token)

      expect(payload[:exp]).to be_within(5).of(24.hours.from_now.to_i)
    end
  end
end
