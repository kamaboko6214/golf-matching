module ApplicationCable
  # WebSocket接続時の認証を担うクラス
  # HTTPリクエストと異なりヘッダーが使いにくいため、クエリパラメータからJWTを受け取る
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # クエリパラメータ（WebSocket接続時）またはAuthorizationヘッダからトークンを取得する
      token = request.params[:token] || request.headers["Authorization"]&.split(" ")&.last
      return reject_unauthorized_connection unless token

      decoded = JWT.decode(
        token,
        ENV.fetch("DEVISE_JWT_SECRET_KEY"),
        true,
        { algorithm: "HS256" }
      )
      # JWTのペイロードの sub フィールドにユーザーIDが格納されている
      user_id = decoded.first["sub"]
      User.find(user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      # トークンが不正またはユーザーが存在しない場合は接続を拒否する
      reject_unauthorized_connection
    end
  end
end
