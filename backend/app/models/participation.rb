class Participation < ApplicationRecord
  belongs_to :user
  belongs_to :recruitment
  belongs_to :chat, optional: true

  enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected' }

  validate :cannot_apply_own_recruitment
  validate :cannot_apply_twice

  private

  # ユーザーが自分の募集に参加できないようにするバリデーション
  def cannot_apply_own_recruitment
    return unless user && recruitment
    if recruitment.user_id == user_id
      errors.add(:base, "自分の募集には参加できません")
    end
  end

  # ユーザーが同じ募集に複数回参加できないようにするバリデーション
  def cannot_apply_twice
    return unless user && recruitment
    if Participation.where(user: user, recruitment: recruitment)
                    .where.not(id: id).exists?
      errors.add(:base, "すでに申請済みです")
    end
  end
end