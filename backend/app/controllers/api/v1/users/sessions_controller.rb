class Api::V1::Users::SessionsController < Devise::SessionsController
  respond_to :json

  def create
    user = User.find_by(email: sign_in_params[:email])
  
    if user&.valid_password?(sign_in_params[:password])
      token = Warden::JWTAuth::UserEncoder.new.call(user, :api_v1_user, nil).first
      response.headers["Authorization"] = "Bearer #{token}"
      render json: {
        message: "ログインしました",
        user: { id: user.id, email: user.email }
      }, status: :ok
    else
      render json: { error: "メールアドレスまたはパスワードが正しくありません" }, status: :unauthorized
    end
  end

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end

  def respond_to_on_destroy
    render json: { message: "ログアウトしました" }, status: :ok
  end
end