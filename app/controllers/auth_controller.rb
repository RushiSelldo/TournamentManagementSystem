class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :signup, :login, :create_user, :authenticate ]

  SECRET_KEY = Rails.application.secret_key_base

  def signup
    @user = User.new
  end

  def create_user
    user = User.new(user_params)

    if user.save
      redirect_to login_path, notice: "Account created successfully! Please log in."
    else
      flash.now[:alert] = user.errors.full_messages.join(", ")
      render :signup, status: :unprocessable_entity
    end
  end

  def login
  end

  def authenticate
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = generate_token(user.id)

      # Store token in an HTTP-only cookie
      cookies.signed[:auth_token] = {
        value: token,
        httponly: true,
        expires: 1.hour.from_now
      }

      redirect_to profile_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = "Invalid email or password"
      render :login, status: :unprocessable_entity
    end
  end

  def logout
    cookies.delete(:auth_token)  # ✅ Delete token cookie on logout
    redirect_to login_path, notice: "Logged out successfully!"
  end

  def profile
    @user = current_user
    unless @user
      redirect_to login_path, alert: "Please log in first"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def generate_token(user_id)
    JWT.encode({ user_id: user_id }, SECRET_KEY, "HS256")
  end
end
