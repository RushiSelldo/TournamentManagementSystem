class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :show, :update ]

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: { user: user }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end


  def update
    user = User.find_by(id: params[:id])

    if user == current_user # Ensure user can only update their own profile
      if user.update(user_params)
        render json: { message: "Profile updated successfully", user: user }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "You are not authorized to update this profile" }, status: :forbidden
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
