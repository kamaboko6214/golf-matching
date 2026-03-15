class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_user!
    authenticate_api_v1_user!
  end

  def current_user
    current_api_v1_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end