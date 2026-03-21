class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat = Chat.find(params[:chat_id])

    if chat.users.include?(connection.current_user)
      stream_for chat
    else
      reject
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def speak(data)
    chat = Chat.find(params[:chat_id])
    return unless chat.users.include?(connection.current_user)

    message = chat.messages.create!(
      user: connection.current_user,
      body: data["body"]
    )

    ChatChannel.broadcast_to(chat, {
      id: message.id,
      body: message.body,
      user: {
        id: connection.current_user.id,
        name: connection.current_user.profile&.name || connection.current_user.email
      },
      created_at: message.created_at
    })
  end
end