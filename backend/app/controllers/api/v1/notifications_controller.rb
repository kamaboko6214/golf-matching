class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!

  # 最新20件の通知と未読数を返す
  def index
    notifications = current_user.notifications.recent.limit(20)
    render json: {
      notifications: notifications.map { |n| notification_json(n) },
      unread_count: current_user.notifications.unread.count
    }
  end

  # 指定した通知を既読にする
  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read: true)
    render json: notification_json(notification)
  end

  # すべての未読通知を一括で既読にする
  def mark_all_read
    # update_all でSQLを1回発行してまとめて更新する
    current_user.notifications.unread.update_all(read: true)
    render json: { message: "すべて既読にしました" }
  end

  private

  def notification_json(notification)
    {
      id: notification.id,
      title: notification.title,
      body: notification.body,
      read: notification.read,
      created_at: notification.created_at,
      link: notification_link(notification)
    }
  end

  # ポリモーフィック関連を利用して通知の種別ごとに遷移先URLを生成する
  def notification_link(notification)
    case notification.notifiable_type
    when 'Recruitment'
      "/matches/#{notification.notifiable_id}"
    else
      nil
    end
  end
end
