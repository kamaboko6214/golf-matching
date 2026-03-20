class Api::V1::ParticipationsController < ApplicationController
  before_action :authenticate_user!

  def create
    recruitment = Recruitment.find(params[:recruitment_id])

    # 自分の募集には参加できない
    if recruitment.user_id == current_user.id
      return render json: { error: "自分の募集には参加できません" }, status: :forbidden
    end

    # すでに申請済みか確認
    if Participation.exists?(user: current_user, recruitment: recruitment)
      return render json: { error: "すでに申請済みです" }, status: :unprocessable_content
    end

    participation = Participation.create!(
      user: current_user,
      recruitment: recruitment,
      status: :pending
    )

    render json: {
      id: participation.id,
      status: participation.status,
      message: "参加申請しました"
    }, status: :created
  end
end