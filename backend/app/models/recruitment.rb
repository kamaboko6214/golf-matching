class Recruitment < ApplicationRecord
  belongs_to :user
  belongs_to :chat, optional: true
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_one :chat
  
  scope :open, -> { where(status: 'open') }
end