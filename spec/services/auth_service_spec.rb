require 'rails_helper'

RSpec.describe AuthService do
  let(:user) { create(:user, password: 'password') }
  let(:auth_service) { described_class.new(user) }
  let(:valid_token) { auth_service.generate_token(user.id) }
  let(:invalid_token) { 'invalid.token' }

  describe "#signup" do
    let(:user_params) { attributes_for(:user) }

    context "when signup is successful" do
      it "returns success" do
        result = auth_service.signup(user_params)
        expect(result[:success]).to be true
      end
    end

    context "when signup fails due to validation" do
      it "returns failure and errors" do
        user_params[:email] = ""
        result = auth_service.signup(user_params)
        expect(result[:success]).to be false
        expect(result[:errors]).not_to be_empty
      end
    end
  end

  describe "#authenticate" do
    context "with valid credentials" do
      it "returns a token and user" do
        result = auth_service.authenticate(user.email, 'password')
        expect(result[:success]).to be true
        expect(result[:user]).to eq(user)
        expect(result[:token]).not_to be_nil
      end
    end

    context "with invalid password" do
      it "returns an error" do
        result = auth_service.authenticate(user.email, 'wrongpassword')
        expect(result[:success]).to be false
        expect(result[:errors]).to include("Invalid email or password")
      end
    end

    context "with non-existent email" do
      it "returns an error" do
        result = auth_service.authenticate('nonexistent@example.com', 'password')
        expect(result[:success]).to be false
        expect(result[:errors]).to include("Invalid email or password")
      end
    end
  end

  describe "#generate_token" do
    it "returns a valid token" do
      token = auth_service.generate_token(user.id)
      expect(token).to be_a(String)
    end
  end

  describe "#decode_token" do
  context "with a valid token" do
    it "decodes the token and returns the payload" do
      decoded = auth_service.decode_token(valid_token)
      expect(decoded["user_id"]).to eq(user.id)
    end
  end

  context "with an invalid token" do
    it "raises an invalid token error" do
      expect { auth_service.decode_token(invalid_token) }.to raise_error("Invalid token")
    end
  end

  context "with an expired token" do
    it "raises a token expired error" do
      expired_token = auth_service.generate_token(user.id)
      travel_to 2.hours.from_now do
        expect { auth_service.decode_token(expired_token) }.to raise_error("Token has expired")
      end
    end
  end
end

  describe "#generate_reset_token" do
    it "returns a valid reset token" do
      token = auth_service.generate_reset_token(user.id)
      expect(token).to be_a(String)
    end
  end

  describe "#decode_reset_token" do
    let(:reset_token) { auth_service.generate_reset_token(user.id) }

    context "with a valid reset token" do
      it "decodes the reset token" do
        decoded = auth_service.decode_reset_token(reset_token)
        expect(decoded["user_id"]).to eq(user.id)
      end
    end

    context "with an expired reset token" do
      it "raises a reset token expired error" do
        reset_token = auth_service.generate_reset_token(user.id)
        travel_to 20.minutes.from_now do
          expect { auth_service.decode_reset_token(reset_token) }.to raise_error("Reset token expired")
        end
      end
    end

    context "with an invalid reset token" do
      it "raises an invalid reset token error" do
        expect { auth_service.decode_reset_token(invalid_token) }.to raise_error("Invalid reset token")
      end
    end
  end

  describe "#reset_password" do
    let(:reset_token) { auth_service.generate_reset_token(user.id) }

    context "with a valid token and user exists" do
      it "resets the password" do
        result = auth_service.reset_password(reset_token, "newpassword")
        expect(result[:success]).to be true
        expect(user.reload.authenticate("newpassword")).to be_truthy
      end
    end

    context "with an invalid token" do
      it "returns failure" do
        result = auth_service.reset_password(invalid_token, "newpassword")
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Invalid token or user not found")
      end
    end

    context "when user does not exist" do
      it "returns failure" do
        payload = { user_id: 9999, exp: 15.minutes.from_now.to_i }
        fake_token = JWT.encode(payload, AuthService::SECRET_KEY, "HS256")

        result = auth_service.reset_password(fake_token, "newpassword")
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Invalid token or user not found")
      end
    end
  end

  describe "#upgrade_to_host" do
    context "when update is successful" do
      it "updates the user role to host" do
        result = auth_service.upgrade_to_host(user)
        expect(result[:success]).to be true
        expect(result[:message]).to eq("You are now a host!")
        expect(user.reload.role).to eq("host")
      end
    end

    context "when update fails" do
      it "returns an error" do
        allow(user).to receive(:update).and_return(false)

        result = auth_service.upgrade_to_host(user)
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Something went wrong. Please try again.")
      end
    end
  end
end
