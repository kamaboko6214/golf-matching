class Api::V1::ChatsController < ApplicationController
    before_action :authenticate_user!
  
    def index
      chats = current_user.chats.includes(:users, :messages)
      render json: chats.map { |c| chat_json(c) }
    end
  
    def show
      chat = current_user.chats.find(params[:id])
      messages = chat.messages.includes(user: :profile).order(:created_at)
      render json: {
        id: chat.id,
        messages: messages.map { |m| message_json(m) }
      }
    end
  
    private
  
    def chat_json(chat)
      last_message = chat.messages.last
      {
        id: chat.id,
        recruitment_title: chat.recruitment&.title,
        members: chat.users.map { |u| { id: u.id, name: u.profile&.name || u.email } },
        last_message: last_message ? {
          body: last_message.body,
          created_at: last_message.created_at
        } : nil
      }
    end
  
    def message_json(message)
      {
        id: message.id,
        body: message.body,
        created_at: message.created_at,
        user: {
          id: message.user.id,
          name: message.user.profile&.name || message.user.email
        }
      }
    end
  end