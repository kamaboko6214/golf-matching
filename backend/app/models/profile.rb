class Profile < ApplicationRecord
    belongs_to :user

    validates :name, presence: true, length: { maximum: 50 }
    validates :average_score, presence: true, numericality: {
      greater_than_or_equal_to: 50,
      less_than_or_equal_to: 200,
      allow_nil: true
    }
  validates :bio, length: { maximum: 500 }
end