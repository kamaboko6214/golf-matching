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

    # 参加申請があったことを募集の作成者に通知
    Notification.create!(
      user: recruitment.user,
      title: "参加申請が届きました",
      body: "「#{recruitment.title}」に#{current_user.profile&.name || current_user.email}さんから参加申請が届きました",
      read: false,
      notifiable: recruitment
    )

    render json: {
      id: participation.id,
      status: participation.status,
      message: "参加申請しました"
    }, status: :created
  end

  def update
    participation = Participation.find(params[:id])

    # 募集の作成者のみが承認・却下できる
    unless participation.recruitment.user_id == current_user.id
      return render json: { error: "権限がありません" }, status: :forbidden
    end

    # 許可する値だけ受け付ける
      unless %w[approved rejected].include?(params[:status])
      return render json: { error: "不正なステータスです" }, status: :unprocessable_content
    end

    participation.update!(status: params[:status])

    # 承認時にチャットルームを作成
    if participation.approved?
      create_chat(participation)
      # 申請者に承認通知
      Notification.create!(
        user: participation.user,
        title: "参加が承認されました",
        body: "「#{participation.recruitment.title}」への参加が承認されました！チャットを開始しましょう",
        read: false,
        notifiable: recruitment
      )
    else
      # 申請者に却下通知
      Notification.create!(
        user: participation.user,
        title: "参加申請が却下されました",
        body: "「#{participation.recruitment.title}」への参加申請が却下されました",
        read: false,
        notifiable: participation.recruitment
      )      
    end

    render json:{
      id: participation.id,
      status: participation.status,
      message: participation.approved? ? "承認しました" : "却下しました"
    }
  end

  private

  def create_chat(participation)
    recruitment = participation.recruitment
  
    # チャットルームがなければ作成（初回承認時）
    if recruitment.chat.nil?
      chat = Chat.create!
      chat.chat_members.create!(user: recruitment.user)
      recruitment.update!(chat: chat)
    else
      chat = recruitment.chat
    end
  
    # 参加者を追加
    unless chat.users.include?(participation.user)
      chat.chat_members.create!(user: participation.user)
    end
  
    participation.update!(chat: chat)
  end
end