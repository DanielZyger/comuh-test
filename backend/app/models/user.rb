class User < ApplicationRecord
  has_many :messages, dependent: :restrict_with_error
  has_many :reactions, dependent: :restrict_with_error

  validates :username, presence: true, uniqueness: true
end
