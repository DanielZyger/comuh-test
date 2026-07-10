FactoryBot.define do
  factory :message do
    user
    community
    content { "A neutral message with no keyword sentiment" }
    user_ip { "127.0.0.1" }
    ai_sentiment_score { 0.0 }
    parent_message { nil }
  end
end
