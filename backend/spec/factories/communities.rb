FactoryBot.define do
  factory :community do
    sequence(:name) { |n| "Community #{n}" }
    description { "A community for testing" }
  end
end
