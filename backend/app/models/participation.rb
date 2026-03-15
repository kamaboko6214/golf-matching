class Participation < ApplicationRecord
    belongs_to :user
    belongs_to :recruitment
  
    enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected' }
end