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
      it 'create a new user and redirect to login' do
        post signup_path, params: params

        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST /login' do
    let!(:user) { create(:user, email: 'rushi@gmail.com', password: 'password', password_confirmation: 'password') }

    context 'with valid credentials' do
      let(:login_params) { { email: user.email, password: 'password' } }



      it 'logs in the user and sets a cookie' do
        post login_path, params: login_params

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(profile_path)
      end
    end
  end
end
