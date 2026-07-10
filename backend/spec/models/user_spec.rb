require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it "returns the messages posted by the user" do
      user = create(:user)
      message = create(:message, user: user)

      expect(user.messages).to contain_exactly(message)
    end

    it "returns the reactions made by the user" do
      user = create(:user)
      reaction = create(:reaction, user: user)

      expect(user.reactions).to contain_exactly(reaction)
    end
  end

  describe "validations" do
    it "requires a username" do
      user = build(:user, username: nil)

      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it "requires a unique username" do
      create(:user, username: "taken")
      user = build(:user, username: "taken")

      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("has already been taken")
    end

    it "is valid with a unique username" do
      expect(build(:user)).to be_valid
    end
  end
end
