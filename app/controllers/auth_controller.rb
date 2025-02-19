class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :signup, :login ]

  SECRET_KEY = Rails.application.secret_key_base

  def signup
    user = User.new(user_params)

    if user.save
      token = generate_token(user.id)
      render json: { user: user, token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = generate_token(user.id)
      render json: { user: user, token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def profile
    render json: { id: @current_user.id, name: @current_user.name, email: @current_user.email, role: @current_user.role }
  end

  private

  def user_params
    params.require(:auth).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def generate_token(user_id)
    JWT.encode({ user_id: user_id }, SECRET_KEY, "HS256")
  end
end
