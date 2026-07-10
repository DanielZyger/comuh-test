class Message < ApplicationRecord
  belongs_to :user
  belongs_to :community
  belongs_to :parent_message, class_name: "Message", optional: true

  has_many :replies, class_name: "Message", foreign_key: :parent_message_id, dependent: :restrict_with_error
  has_many :reactions, dependent: :restrict_with_error

  validates :content, presence: true
  validates :user_ip, presence: true
  validates :ai_sentiment_score, numericality: { in: -1.0..1.0 }, allow_nil: true
end
