class Api::V1::ParticipationsController < ApplicationController
  before_action :authenticate_user!

  # 参加申請を作成する
  # 自分の募集への申請はコントローラー層で早期リターン（モデルのバリデーションと二重チェック）
  def create
    recruitment = Recruitment.find(params[:recruitment_id])

    if recruitment.user_id == current_user.id
      return render json: { error: "自分の募集には参加できません" }, status: :forbidden
    end

    participation = Participation.new(
      user: current_user,
      recruitment: recruitment,
      status: :pending
    )

    if participation.save
      # 募集の作成者に申請通知を送る
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
    else
      render json: { errors: participation.errors.full_messages }, status: :unprocessable_content
    end
  end

  # 参加申請を承認または却下する（募集の作成者のみ操作可能）
  def update
    participation = Participation.find(params[:id])

    unless participation.recruitment.user_id == current_user.id
      return render json: { error: "権限がありません" }, status: :forbidden
    end

    unless %w[approved rejected].include?(params[:status])
      return render json: { error: "不正なステータスです" }, status: :unprocessable_content
    end

    # チャット作成・通知・ステータス更新を一括でコミットし、途中失敗時はロールバックする
    ActiveRecord::Base.transaction do
      if participation.update(status: params[:status])
        if participation.approved?
          create_chat(participation)
          Notification.create!(
            user: participation.user,
            title: "参加が承認されました",
            body: "「#{participation.recruitment.title}」への参加が承認されました！チャットを開始しましょう",
            read: false,
            notifiable: participation.recruitment
          )
        else
          Notification.create!(
            user: participation.user,
            title: "参加申請が却下されました",
            body: "「#{participation.recruitment.title}」への参加申請が却下されました",
            read: false,
            notifiable: participation.recruitment
          )
        end

        render json: {
          id: participation.id,
          status: participation.status,
          message: participation.approved? ? "承認しました" : "却下しました"
        }
      else
        render json: { errors: participation.errors.full_messages }, status: :unprocessable_content
      end
    end
  end

  private

  # 承認時にチャットルームを作成し、投稿者と参加者を追加する
  # 同一募集に複数人が承認された場合は既存チャットルームに追加する（1募集1チャット）
  def create_chat(participation)
    recruitment = participation.recruitment

    if recruitment.chat.nil?
      chat = Chat.create!
      chat.chat_members.create!(user: recruitment.user)
      recruitment.update!(chat: chat)
    else
      chat = recruitment.chat
    end

    unless chat.users.include?(participation.user)
      chat.chat_members.create!(user: participation.user)
    end

    participation.update!(chat: chat)
  end
end
