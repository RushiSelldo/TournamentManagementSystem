class AuthController < ApplicationController
  layout false, only: [ :signup, :login ]
  skip_before_action :authenticate_user!, only: [ :signup, :login, :create_user, :authenticate, :forgot_password, :reset_password ]
  before_action :redirect_if_authenticated, only: [ :signup, :login ]

  rescue_from StandardError, with: :handle_internal_server_error
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def signup
    @user = User.new
  end

  def create_user
    service = AuthService.new
    result = service.signup(user_params)

    if result[:success]
      respond_to do |format|
        format.html { redirect_to login_path, notice: "Account created successfully! Please log in." }
        format.json { render json: { message: "Account created successfully" }, status: :created }
      end
    else
      respond_with_errors(result[:errors])
    end
  end

  def login
  end

  def authenticate
    return render_missing_params unless params[:email].present? && params[:password].present?

    service = AuthService.new
    result = service.authenticate(params[:email], params[:password])

    if result[:success]
      cookies.signed[:auth_token] = {
        value: result[:token],
        httponly: true,
        expires: 1.hour.from_now
      }

      respond_to do |format|
        format.html { redirect_to profile_path, notice: "Logged in successfully!" }
        format.json { render json: { message: "Logged in successfully", token: result[:token] }, status: :ok }
      end
    else
      render_invalid_credentials
    end
  end

  def logout
    cookies.delete(:auth_token)
    respond_to do |format|
      format.html { redirect_to login_path, notice: "Logged out successfully!" }
      format.json { render json: { message: "Logged out successfully" }, status: :ok }
    end
  end

  def upgrade_to_host
    result = AuthService.new(current_user).upgrade_to_host(current_user)

    if result[:success]
      redirect_to new_host_tournament_path, notice: result[:message]
    else
      redirect_to participant_dashboard_path, alert: result[:error]
    end
  end

  def profile
    @user = current_user

    if @user
      respond_to do |format|
        format.html
        format.json { render json: @user, status: :ok }
      end
    else
      render_unauthorized
    end
  end

  def forgot_password
    user = User.find_by(email: params[:email])

    if user
      token = AuthService.new.generate_reset_token(user.id)
      render json: { reset_token: token, message: "Use this token to reset your password." }, status: :ok
    else
      render json: { error: "Email not found" }, status: :not_found
    end
  end

  def reset_password
    token = params[:token]
    new_password = params[:password]

    return render json: { error: "Token and password are required" }, status: :bad_request unless token.present? && new_password.present?

    service = AuthService.new
    result = service.reset_password(token, new_password)

    if result[:success]
      render json: { message: result[:message] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  rescue ActionController::ParameterMissing
    render json: { error: "Missing user parameters" }, status: :bad_request
  end

  def redirect_if_authenticated
    redirect_to profile_path, notice: "You are already logged in." if current_user
  end
end

def respond_with_errors(errors)
  respond_to do |format|
    format.html do
      flash[:alert] = errors.join(", ")
      redirect_to signup_path
    end
    format.json do
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end
end


def handle_internal_server_error(error)
  Rails.logger.error("Internal Server Error: #{error.message}")
  render json: { error: "Something went wrong. Please try again later." }, status: :internal_server_error
end

def handle_unprocessable_entity(error)
  render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
end

def handle_not_found(error)
  render json: { error: "Resource not found" }, status: :not_found
end



def render_missing_params
  render json: { error: "Email and password are required" }, status: :bad_request
end

def render_invalid_credentials
  respond_to do |format|
    format.html do
      flash.now[:alert] = "Invalid email or password"
      render :login, status: :unprocessable_entity
    end
    format.json { render json: { error: "Invalid email or password" }, status: :unauthorized }
  end
end

def render_unauthorized
  respond_to do |format|
    format.html { redirect_to login_path, alert: "Please log in first" }
    format.json { render json: { error: "Unauthorized. Please log in." }, status: :unauthorized }
  end
end

def respond_with_errors(user)
  respond_to do |format|
    format.html do
      flash.now[:alert] = user.errors.full_messages.join(", ")
      render :signup, status: :unprocessable_entity
    end
    format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
  end
end
