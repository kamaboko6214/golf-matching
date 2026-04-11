class Api::V1::MyPagesController < ApplicationController
  before_action :authenticate_user!

  # マイページに必要な3種類のデータをまとめて返す
  def show
    render json: {
      posted_recruitments: posted_recruitments,
      pending_participations: pending_participations,
      approved_participations: approved_participations
    }
  end

  private

  # 自分が投稿した募集一覧（N+1対策で participations を一括取得）
  def posted_recruitments
    current_user.recruitments
                .includes(:participations)
                .order(created_at: :desc)
                .map do |r|
      {
        id: r.id,
        title: r.title,
        play_date: r.play_date,
        prefecture: r.prefecture,
        status: r.status,
        # インクルード済みのためSQLを発行せずメモリ内で数える
        participations_count: r.participations.size
      }
    end
  end

  # 申請中（pending）の参加申請一覧
  def pending_participations
    current_user.participations.where(status: :pending)
                .includes(recruitment: :user)
                .order(created_at: :desc)
                .map { |p| participation_json(p) }
  end

  # 承認済み（approved）の参加予定一覧
  def approved_participations
    current_user.participations.where(status: :approved)
                .includes(recruitment: :user)
                .order(created_at: :desc)
                .map { |p| participation_json(p) }
  end

  def participation_json(participation)
    r = participation.recruitment
    {
      id: participation.id,
      chat_id: participation.recruitment.chat_id,
      recruitment: {
        id: r.id,
        title: r.title,
        play_date: r.play_date,
        prefecture: r.prefecture,
        course_name: r.course_name
      }
    }
  end
end
