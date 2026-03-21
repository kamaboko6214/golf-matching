class AddChatIdToRecruitments < ActiveRecord::Migration[7.1]
  def change
    add_reference :recruitments, :chat, null: true, foreign_key: true
  end
end