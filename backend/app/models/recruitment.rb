class Recruitment < ApplicationRecord
    belongs_to :user
    has_many :participations, dependent: :destroy
    has_many :participants, through: :participations, source: :user
  
    scope :open, -> { where(status: 'open') }
end