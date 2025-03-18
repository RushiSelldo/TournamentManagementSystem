require 'rails_helper'

RSpec.describe AuthController, type: :request do
  describe 'POST /signup' do
    let(:params) do
      {
        user: {
          name: 'Rushi',
          email: 'rushi@gmail.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end

    context 'when valid parameters are provided' do
      it 'creates a new user and redirects to login' do
        post signup_path, params: params
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when email is already taken' do
      before { create(:user, email: 'rushi@gmail.com') }
      it 'does not create a new user' do
        post signup_path, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /login' do
    let!(:user) { create(:user, email: 'rushi@gmail.com', password: 'password') }

    context 'with valid credentials' do
      it 'logs in the user and redirects to profile' do
        post login_path, params: { email: user.email, password: 'password' }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  describe 'DELETE /logout' do
    it 'logs out the user and redirects to login' do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe 'GET /profile' do
    let!(:user) { create(:user, email: 'rushi@gmail.com', password: 'password') }

    context 'when user is logged in' do
      before do
        post login_path, params: { email: user.email, password: 'password' }
        @auth_token = response.cookies['auth_token']
      end

      it 'returns user profile' do
        get profile_path, headers: { 'Cookie' => "auth_token=#{@auth_token}" }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to login' do
        get profile_path
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
