require "rails_helper"

RSpec.describe Reaction do
  describe "validations" do
    it "requires a reaction_type" do
      reaction = build(:reaction, reaction_type: nil)

      expect(reaction).not_to be_valid
      expect(reaction.errors[:reaction_type]).to include("can't be blank")
    end

    it "only accepts like, love or insightful" do
      reaction = build(:reaction, reaction_type: "dislike")

      expect(reaction).not_to be_valid
      expect(reaction.errors[:reaction_type]).to include("is not included in the list")
    end

    it "accepts each of the defined reaction types" do
      message = create(:message)

      Reaction::REACTION_TYPES.each do |type|
        reaction = build(:reaction, message: message, user: create(:user), reaction_type: type)
        expect(reaction).to be_valid
      end
    end

    it "prevents the same user from reacting twice with the same type on the same message" do
      existing = create(:reaction, reaction_type: "like")
      duplicate = build(:reaction, message: existing.message, user: existing.user, reaction_type: "like")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("já reagiu com esse tipo de reação nesta mensagem")
    end

    it "allows the same user to react with a different type on the same message" do
      existing = create(:reaction, reaction_type: "like")
      other_type = build(:reaction, message: existing.message, user: existing.user, reaction_type: "love")

      expect(other_type).to be_valid
    end

    it "allows different users to react with the same type on the same message" do
      existing = create(:reaction, reaction_type: "like")
      other_user = build(:reaction, message: existing.message, user: create(:user), reaction_type: "like")

      expect(other_user).to be_valid
    end
  end

  describe "database-level uniqueness constraint" do
    it "rejects a duplicate reaction even when the model validation is bypassed" do
      reaction = build(:reaction, reaction_type: "like")
      reaction.save!(validate: false)

      duplicate = build(:reaction, message: reaction.message, user: reaction.user, reaction_type: "like")

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
