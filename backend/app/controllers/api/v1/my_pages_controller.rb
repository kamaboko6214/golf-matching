class Api::V1::MyPagesController < ApplicationController
    before_action :authenticate_user!
  
    def show
      render json: {
        posted_recruitments: posted_recruitments,
        pending_participations: pending_participations,
        approved_participations: approved_participations,
      }
    end
  
    private
  
    def posted_recruitments
      current_user.recruitments.order(created_at: :desc).map do |r|
        {
          id: r.id,
          title: r.title,
          play_date: r.play_date,
          prefecture: r.prefecture,
          status: r.status,
          participations_count: r.participations.count,
        }
      end
    end
  
    def pending_participations
      current_user.participations.where(status: :pending)
                  .includes(recruitment: :user)
                  .order(created_at: :desc)
                  .map { |p| participation_json(p) }
    end
  
    def approved_participations
      current_user.participations.where(status: :approved)
                  .includes(recruitment: :user)
                  .order(created_at: :desc)
                  .map { |p| participation_json(p) }
    end
  
    def participation_json(participation)
      r = participation.recruitment
      {
        id: participation.id,
        chat_id: participation.recruitment.chat_id,
        recruitment: {
          id: r.id,
          title: r.title,
          play_date: r.play_date,
          prefecture: r.prefecture,
          course_name: r.course_name,
        }
      }
    end
  end