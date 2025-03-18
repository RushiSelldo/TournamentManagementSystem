class AuthService
  SECRET_KEY = Rails.application.secret_key_base

  def initialize(user = nil)
    @user = user
  end


  def signup(user_params)
    user = User.new(user_params)
    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  end


  def authenticate(email, password)
    user = User.find_by(email: email)

    if user&.authenticate(password)
      token = generate_token(user.id)
      { success: true, user: user, token: token }
    else
      { success: false, errors: [ "Invalid email or password" ] }
    end
  end


  def generate_token(user_id)
    JWT.encode({ user_id: user_id, exp: 1.hour.from_now.to_i }, SECRET_KEY, "HS256")
  end


  def decode_token(token)
    JWT.decode(token, SECRET_KEY, true, algorithm: "HS256").first
  rescue JWT::ExpiredSignature
    raise "Token has expired"
  rescue JWT::DecodeError
    raise "Invalid token"
  end

  def generate_reset_token(user_id)
    JWT.encode({ user_id: user_id, exp: 15.minutes.from_now.to_i }, SECRET_KEY, "HS256")
  end

  def decode_reset_token(token)
    JWT.decode(token, SECRET_KEY, true, algorithm: "HS256").first
  rescue JWT::ExpiredSignature
    raise "Reset token expired"
  rescue JWT::DecodeError
    raise "Invalid reset token"
  end


  def reset_password(token, new_password)
    payload = decode_reset_token(token)
    user = User.find_by(id: payload["user_id"])

    if user
      user.update(password: new_password)
      { success: true, message: "Password successfully reset" }
    else
      { success: false, error: "Invalid token or user not found" }
    end
  end


  def upgrade_to_host(user)
    if user.update(role: "host")
      { success: true, message: "You are now a host!" }
    else
      { success: false, error: "Something went wrong. Please try again." }
    end
  end
end
