class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def authenticate_user!
    @current_user = current_user
    redirect_to login_path, alert: "Please log in first" unless @current_user
  end

  def current_user
    token = cookies.signed[:auth_token]  # ✅ Read token from HTTP-only cookie
    return unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
      user_id = decoded_token[0]["user_id"]
      @current_user ||= User.find_by(id: user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
