class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_one :profile, dependent: :destroy
  has_many :recruitments, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :participated_recruitments, through: :participations, source: :recruitment
  has_many :chat_members, dependent: :destroy
  has_many :chats, through: :chat_members
  has_many :messages, dependent: :destroy
end