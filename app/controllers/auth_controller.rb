class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :signup, :login, :create_user, :authenticate ]

  SECRET_KEY = Rails.application.secret_key_base

  rescue_from StandardError, with: :handle_internal_server_error
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def signup
    @user = User.new
  end

  def create_user
    user = User.new(user_params)

    if user.save
      respond_to do |format|
        format.html { redirect_to login_path, notice: "Account created successfully! Please log in." }
        format.json { render json: { message: "Account created successfully" }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = user.errors.full_messages.join(", ")
          render :signup, status: :unprocessable_entity
        end
        format.json { render json: { errors: user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def login
  end

  def authenticate
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = generate_token(user.id)


      cookies.signed[:auth_token] = {
        value: token,
        httponly: true,
        expires: 1.hour.from_now
      }

      respond_to do |format|
        format.html { redirect_to profile_path, notice: "Logged in successfully!" }
        format.json { render json: { message: "Logged in successfully", token: token }, status: :ok }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "Invalid email or password"
          render :login, status: :unprocessable_entity
        end
        format.json { render json: { error: "Invalid email or password" }, status: :unauthorized }
      end
    end
  end

  def logout
    cookies.delete(:auth_token)

    respond_to do |format|
      format.html { redirect_to login_path, notice: "Logged out successfully!" }
      format.json { render json: { message: "Logged out successfully" }, status: :ok }
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
      respond_to do |format|
        format.html { redirect_to login_path, alert: "Please log in first" }
        format.json { render json: { error: "Unauthorized. Please log in." }, status: :unauthorized }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def generate_token(user_id)
    JWT.encode({ user_id: user_id, exp: 1.hour.from_now.to_i }, SECRET_KEY, "HS256")
  end

  # Error Handling Methods

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
end
