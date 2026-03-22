class Recruitment < ApplicationRecord
  belongs_to :user
  belongs_to :chat, optional: true
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_one_attached :image
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :course_name, length: { maximum: 100 }
  validates :needed_players, presence: true, numericality: {
    only_integer: true,
    greater_than: 0,
    less_than_or_equal_to: 10
  }
  validates :play_date, presence: true
  validates :prefecture, presence: true
  validates :status, inclusion: { in: %w[open closed] }
  validate :play_date_cannot_be_in_the_past

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
    recruitments.recent
  end

  private
  def play_date_cannot_be_in_the_past
    if play_date.present? && play_date < Date.today
      errors.add(:play_date, "は今日以降の日付を選択してください")
    end
  end
end