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
end
