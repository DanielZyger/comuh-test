class Reaction < ApplicationRecord
  REACTION_TYPES = %w[like love insightful].freeze

  belongs_to :message
  belongs_to :user

  validates :reaction_type, presence: true, inclusion: { in: REACTION_TYPES }
  validates :user_id, uniqueness: {
    scope: [ :message_id, :reaction_type ],
    message: "já reagiu com esse tipo de reação nesta mensagem"
  }
end
