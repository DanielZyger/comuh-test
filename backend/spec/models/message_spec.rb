require "rails_helper"

RSpec.describe Message do
  describe "associations" do
    it "returns its replies through parent_message_id" do
      parent = create(:message)
      reply = create(:message, parent_message: parent, community: parent.community)

      expect(parent.replies).to contain_exactly(reply)
      expect(reply.parent_message).to eq(parent)
    end

    it "returns the reactions made on the message" do
      message = create(:message)
      reaction = create(:reaction, message: message)

      expect(message.reactions).to contain_exactly(reaction)
    end

    it "allows a top-level message to have no parent" do
      message = create(:message, parent_message: nil)

      expect(message.parent_message).to be_nil
    end
  end

  describe "validations" do
    it "requires content" do
      message = build(:message, content: nil)

      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end

    it "requires a user_ip" do
      message = build(:message, user_ip: nil)

      expect(message).not_to be_valid
      expect(message.errors[:user_ip]).to include("can't be blank")
    end

    it "requires an associated user" do
      message = build(:message, user: nil)

      expect(message).not_to be_valid
      expect(message.errors[:user]).to include("must exist")
    end

    it "requires an associated community" do
      message = build(:message, community: nil)

      expect(message).not_to be_valid
      expect(message.errors[:community]).to include("must exist")
    end

    it "allows a nil sentiment score" do
      expect(build(:message, ai_sentiment_score: nil)).to be_valid
    end

    it "accepts sentiment scores within -1.0..1.0" do
      expect(build(:message, ai_sentiment_score: -1.0)).to be_valid
      expect(build(:message, ai_sentiment_score: 1.0)).to be_valid
    end

    it "rejects sentiment scores outside -1.0..1.0" do
      message = build(:message, ai_sentiment_score: 1.5)

      expect(message).not_to be_valid
      expect(message.errors[:ai_sentiment_score]).to be_present
    end
  end
end
