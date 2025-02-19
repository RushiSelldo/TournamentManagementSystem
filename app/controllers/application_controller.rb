class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    return render_unauthorized unless token

    secret_key = Rails.application.secret_key_base # Make sure this matches the one used for encoding

    begin
      decoded_token = JWT.decode(token, secret_key, true, algorithm: "HS256")

      # Ensure decoded_token is valid and contains user_id
      if decoded_token.present? && decoded_token[0].is_a?(Hash) && decoded_token[0]["user_id"]
        user_id = decoded_token[0]["user_id"]
        @current_user = User.find_by(id: user_id)
      end

      render_unauthorized unless @current_user
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
      Rails.logger.error("JWT Error: #{e.message}") # Logs the actual error for debugging
      render_unauthorized
    end
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
