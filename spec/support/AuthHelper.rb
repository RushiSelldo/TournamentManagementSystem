# spec/support/auth_helper.rb
module AuthHelper
  def authenticate(user)
    token = JsonWebToken.encode(user_id: user.id) # Generate a JWT token
    cookies[:auth_token] = token # Set the token in the cookies
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
