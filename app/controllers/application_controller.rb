class ApplicationController < ActionController::Base
  helper_method :current_user  # Make it available in views

  # include Pundit::Authorization

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_to root_path, alert: "You are not authorized to perform this action." }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  def authenticate_user!
    @current_user = current_user
    if @current_user.nil?
      respond_to do |format|
        format.html { redirect_to login_path, alert: "Please log in first" }
        format.json { render json: { error: "Unauthorized. Please log in." }, status: :unauthorized }
      end
    end
  end

  def current_user
    # binding.pry
    token = cookies.signed[:auth_token]  # ✅ Consistent Cookie Name
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
