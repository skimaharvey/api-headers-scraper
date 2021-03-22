class ApplicationController < ActionController::API
    private
    def token(user_id)
      #TODO ADD SOME EXPIRATION TO TOKEN
      payload = { user_id: user_id }
      secret_token = JWT.encode(payload, hmac_secret, 'HS256')
      User.find(user_id).update(token: secret_token)
      secret_token
    end
  
    def hmac_secret
    #   ENV["API_SECRET_KEY"]
        "somernadomwapikey"
    end
  
    def client_has_valid_token?
      !!current_user_id
    end
    def check_current_user(token)
      user = User.find_by(token: token)
      if !user.nil?
        user.id
      else
        return nil
      end
    end

    def current_user_id
      begin
        token = request.headers["Authorization"]
        decoded_array = JWT.decode(token, hmac_secret, true, { algorithm: 'HS256' })
        payload = decoded_array.first
      rescue #JWT::VerificationError
        return nil
      end
      payload["user_id"]
    end
  
    def require_login
      render json: {error: 'Not authorized'}, status: :unauthorized if !client_has_valid_token?
    end
end
