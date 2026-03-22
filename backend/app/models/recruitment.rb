class Recruitment < ApplicationRecord
  belongs_to :user
  belongs_to :chat, optional: true
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_one_attached :image
  
  scope :open, -> { where(status: 'open') }
  scope :by_prefecture, ->(pref) { where(prefecture: pref) }
  scope :from_date, ->(date) { where('play_date >= ?', date) }
  scope :to_date, ->(date) { where('play_date <= ?', date) }
  scope :by_keyword, ->(keyword) { where('title ILIKE ? OR description ILIKE ? OR course_name ILIKE ?', "%#{keyword}%", "%#{keyword}%", "%#{keyword}%") }

  scope :recent, -> { order(created_at: :desc) }

  def self.search(params)                        
    recruitments = Recruitment.all
    recruitments = recruitments.by_prefecture(params[:prefecture]) if params[:prefecture].present?
    recruitments = recruitments.from_date(params[:from_date]) if params[:from_date].present?
    recruitments = recruitments.to_date(params[:to_date]) if params[:to_date].present?
    recruitments = recruitments.by_keyword(params[:keyword]) if params[:keyword].present?
    recruitments
  end
end