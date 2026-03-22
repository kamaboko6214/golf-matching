class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    notifications = current_user.notifications.recent.limit(20)
    render json: {
      notifications: notifications.map { |n| notification_json(n) },
      unread_count: current_user.notifications.unread.count
    }
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read: true)
    render json: notification_json(notification)
  end

  def mark_all_read
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

  def notification_link(notification)
    case notification.notifiable_type
    when 'Recruitment'
        "/matches/#{notification.notifiable_id}"
    else
        nil
    end
  end

end