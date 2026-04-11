class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    user = User.find(params[:id])
    profile = user.profile

    render json: {
      id: user.id,
      email: user.email,
      name: profile&.name,
      average_score: profile&.average_score,
      prefecture: profile&.prefecture,
      bio: profile&.bio,
      image_url: profile_image_url(profile),
      recruitments: user.recruitments.open.order(created_at: :desc).limit(5).map do |r|
        {
          id: r.id,
          title: r.title,
          play_date: r.play_date,
          prefecture: r.prefecture,
          course_name: r.course_name,
          needed_players: r.needed_players,
        }
      end
    }
  end

  private

  def profile_image_url(profile)
    return nil unless profile&.image&.attached?

    url_for(profile.image)
  end
end