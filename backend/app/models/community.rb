class Community < ApplicationRecord
  has_many :messages, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
