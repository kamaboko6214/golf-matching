class Participation < ApplicationRecord
    belongs_to :user
    belongs_to :recruitment
    belongs_to :chat, optional: true

    enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected' }
end