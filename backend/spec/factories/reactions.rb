FactoryBot.define do
  factory :reaction do
    message
    user
    reaction_type { "like" }
  end
end
