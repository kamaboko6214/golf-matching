module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token] || request.headers["Authorization"]&.split(" ")&.last
      return reject_unauthorized_connection unless token

      decoded = JWT.decode(
        token,
        ENV.fetch("DEVISE_JWT_SECRET_KEY"),
        true,
        { algorithm: "HS256" }
      )
      user_id = decoded.first["sub"]
      User.find(user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      reject_unauthorized_connection
    end
  end
end