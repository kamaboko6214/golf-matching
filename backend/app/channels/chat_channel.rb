class ChatChannel < ApplicationCable::Channel
  # クライアントがチャンネルを購読した際に呼ばれる
  # チャットのメンバーのみストリームを開始し、非メンバーは接続を拒否する
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

  # クライアントからメッセージを受信し、DBに保存後にチャンネル全員へブロードキャストする
  def speak(data)
    chat = Chat.find(params[:chat_id])
    # 購読後にメンバー資格が失われたケースを防ぐため再チェックする
    return unless chat.users.include?(connection.current_user)

    message = chat.messages.new(
      user: connection.current_user,
      body: data["body"]
    )

    if message.save
      # このチャットを購読している全クライアントにリアルタイム配信する
      ChatChannel.broadcast_to(chat, {
        id: message.id,
        body: message.body,
        user: {
          id: connection.current_user.id,
          name: connection.current_user.profile&.name || connection.current_user.email
        },
        created_at: message.created_at
      })
    else
      # 保存失敗時は送信者のみにエラーを返す
      transmit({ error: message.errors.full_messages })
    end
  end
end
