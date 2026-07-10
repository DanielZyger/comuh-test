require "rails_helper"

RSpec.describe TopMessagesQuery do
  describe "#call" do
    it "ranks messages by (reactions * 1.5 + replies * 1.0), highest first" do
      community = create(:community)
      low_engagement = create(:message, community: community)
      high_engagement = create(:message, community: community)

      create_list(:reaction, 2, message: high_engagement, reaction_type: "like")
      create(:reaction, message: high_engagement, reaction_type: "love")
      create(:message, community: community, parent_message: high_engagement)

      results = described_class.new(community, limit: 10).call

      expect(results.map(&:id)).to eq([ high_engagement.id, low_engagement.id ])
    end

    it "does not include replies as top-level candidates" do
      community = create(:community)
      parent = create(:message, community: community)
      create(:message, community: community, parent_message: parent)

      results = described_class.new(community, limit: 10).call

      expect(results.map(&:id)).to contain_exactly(parent.id)
    end

    it "only considers messages from the given community" do
      community = create(:community)
      other_community = create(:community)
      create(:message, community: other_community)
      own_message = create(:message, community: community)

      results = described_class.new(community, limit: 10).call

      expect(results.map(&:id)).to contain_exactly(own_message.id)
    end

    it "respects the limit" do
      community = create(:community)
      create_list(:message, 3, community: community)

      results = described_class.new(community, limit: 2).call

      expect(results.size).to eq(2)
    end
  end
end
