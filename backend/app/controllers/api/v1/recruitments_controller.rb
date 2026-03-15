class Api::V1::RecruitmentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_recruitment, only: [:show, :update, :destroy]
  
    def index
      recruitments = Recruitment.open
                                .includes(user: :profile)
                                .order(created_at: :desc)
      render json: recruitments.map { |r| recruitment_json(r) }
    end
  
    def show
      render json: recruitment_json(@recruitment)
    end
  
    def create
      recruitment = current_user.recruitments.build(recruitment_params)
      if recruitment.save
        render json: recruitment_json(recruitment), status: :created
      else
        render json: { errors: recruitment.errors.full_messages }, status: :unprocessable_content
      end
    end
  
    def update
      if @recruitment.user_id == current_user.id
        if @recruitment.update(recruitment_params)
          render json: recruitment_json(@recruitment)
        else
          render json: { errors: @recruitment.errors.full_messages }, status: :unprocessable_content
        end
      else
        render json: { error: "権限がありません" }, status: :forbidden
      end
    end
  
    def destroy
      if @recruitment.user_id == current_user.id
        @recruitment.destroy
        render json: { message: "削除しました" }
      else
        render json: { error: "権限がありません" }, status: :forbidden
      end
    end
  
    private
  
    def set_recruitment
      @recruitment = Recruitment.find(params[:id])
    end
  
    def recruitment_params
      params.require(:recruitment).permit(
        :title, :description, :play_date,
        :course_name, :prefecture, :needed_players
      )
    end
  
    # responseのフォーマット
    def recruitment_json(recruitment)
      {
        id: recruitment.id,
        title: recruitment.title,
        description: recruitment.description,
        play_date: recruitment.play_date,
        course_name: recruitment.course_name,
        prefecture: recruitment.prefecture,
        needed_players: recruitment.needed_players,
        status: recruitment.status,
        created_at: recruitment.created_at,
        user: {
          id: recruitment.user.id,
          email: recruitment.user.email,
          name: recruitment.user.profile&.name
        }
      }
    end
  end