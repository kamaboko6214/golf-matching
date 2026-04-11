class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # 登録後の自動サインインをスキップ
  def create
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      render json: {
        message: "登録しました",
        user: { id: resource.id, email: resource.email }
      }, status: :created
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password)
  end
end
