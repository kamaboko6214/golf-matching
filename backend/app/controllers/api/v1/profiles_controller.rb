class Api::V1::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    profile = current_user.profile
    if profile
      render json: profile_json(profile)
    else
      render json: nil, status: :ok
    end
  end

  def create
    profile = current_user.build_profile(profile_params)
    if profile.save
      render json: profile_json(profile), status: :created
    else
      render json: { errors: profile.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    profile = current_user.profile || current_user.build_profile
    if profile.update(profile_params)
      render json: profile_json(profile)
    else
      render json: { errors: profile.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :handicap, :prefecture, :bio)
  end

  def profile_json(profile)
    {
      id: profile.id,
      name: profile.name,
      handicap: profile.handicap,
      prefecture: profile.prefecture,
      bio: profile.bio,
      email: current_user.email
    }
  end
end