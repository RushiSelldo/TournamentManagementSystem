class ApplicationController < ActionController::Base
  helper_method :current_user

  include Pundit::Authorization

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotUnique, with: :handle_duplicate_email

  private


  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
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


  def handle_duplicate_email(error)
    Rails.logger.error("Duplicate Record Error: #{error.message}")
    render json: { error: "Email already taken" }, status: :unprocessable_entity
  end

  def current_user
    token = cookies.signed[:auth_token]
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
