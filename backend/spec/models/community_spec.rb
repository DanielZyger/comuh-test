require "rails_helper"

RSpec.describe Community do
  describe "associations" do
    it "returns the messages posted in the community" do
      community = create(:community)
      message = create(:message, community: community)

      expect(community.messages).to contain_exactly(message)
    end
  end

  describe "validations" do
    it "requires a name" do
      community = build(:community, name: nil)

      expect(community).not_to be_valid
      expect(community.errors[:name]).to include("can't be blank")
    end

    it "requires a unique name" do
      create(:community, name: "Rubyists")
      community = build(:community, name: "Rubyists")

      expect(community).not_to be_valid
      expect(community.errors[:name]).to include("has already been taken")
    end

    it "allows a blank description" do
      expect(build(:community, description: nil)).to be_valid
    end
  end
end
