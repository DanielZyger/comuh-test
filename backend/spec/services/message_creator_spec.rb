require "rails_helper"

RSpec.describe MessageCreator do
  let(:community) { create(:community) }

  describe "#call" do
    it "creates a new user when the username does not exist yet" do
      expect {
        described_class.new(
          username: "new_person",
          community_id: community.id,
          content: "Olá comunidade",
          user_ip: "10.0.0.1"
        ).call
      }.to change(User, :count).by(1)
    end

    it "reuses an existing user with the same username" do
      existing_user = create(:user, username: "regular")

      expect {
        described_class.new(
          username: "regular",
          community_id: community.id,
          content: "Outra mensagem",
          user_ip: "10.0.0.1"
        ).call
      }.not_to change(User, :count)

      message = Message.last
      expect(message.user).to eq(existing_user)
    end

    it "computes the sentiment score from the content" do
      message = described_class.new(
        username: "sentiment_user",
        community_id: community.id,
        content: "Que dia excelente, adorei",
        user_ip: "10.0.0.1"
      ).call

      expect(message.ai_sentiment_score).to eq(1.0)
    end

    it "sets the parent_message_id when creating a reply" do
      parent = create(:message, community: community)

      reply = described_class.new(
        username: "replier",
        community_id: community.id,
        content: "Concordo!",
        user_ip: "10.0.0.1",
        parent_message_id: parent.id
      ).call

      expect(reply.parent_message).to eq(parent)
    end

    it "does not create a new user when the message is invalid" do
      expect {
        expect {
          described_class.new(
            username: "orphan_candidate",
            community_id: community.id,
            content: nil,
            user_ip: "10.0.0.1"
          ).call
        }.to raise_error(ActiveRecord::RecordInvalid)
      }.not_to change(User, :count)
    end
  end
end
