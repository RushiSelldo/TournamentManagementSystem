require 'rails_helper'

RSpec.describe Host::TournamentsController, type: :request do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, role: 'admin') }
  let(:tournament) { create(:tournament, user: user) }
  let(:valid_attributes) { { tournament: { name: 'Test Tournament', location: 'Test Location', start_date: Date.tomorrow } } }
  let(:invalid_attributes) { { tournament: { name: nil, location: nil, start_date: nil } } }

  describe 'GET /host/tournaments/count' do
    it 'returns the total count of tournaments for an admin' do
      sign_in admin_user
      create_list(:tournament, 3, user: user)
      get '/host/tournaments/count'
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['total_tournaments']).to eq(3)
    end

    it 'returns 403 when user role is not admin' do
      sign_in user
      get '/host/tournaments/count'
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)['error']).to eq("Not authorized")
    end
  end

  describe 'GET /host/tournaments' do
    it 'returns a successful response' do
      sign_in user
      get '/host/tournaments'
      expect(response).to have_http_status(:ok)
    end

    it 'returns tournaments in JSON format' do
      sign_in user
      create_list(:tournament, 2, user: user)
      get '/host/tournaments.json'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it 'returns 403 for non-signed-in users' do
      get '/host/tournaments'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /host/tournaments/:id' do
    it 'returns a successful response' do
      sign_in user
      get "/host/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:ok)
    end

    it 'returns tournament in JSON format' do
      sign_in user
      get "/host/tournaments/#{tournament.id}.json"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['id']).to eq(tournament.id)
    end

    it 'returns 404 for non-existent tournament' do
      sign_in user
      get '/host/tournaments/999'
      expect(response).to have_http_status(:not_found)
    end

    it 'returns 403 for non-signed-in users' do
      get "/host/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns the correct pundit error message' do
      sign_in user # You need to sign in a user to trigger the authorization in this case.
      get "/host/tournaments/#{tournament.id}.json"
      expect(JSON.parse(response.body)['error']).to eq("Not authorized")
    end
  end

  describe 'GET /host/tournaments/new' do
    it 'returns a successful response' do
      sign_in user
      get '/host/tournaments/new'
      expect(response).to have_http_status(:ok)
    end

    it 'returns 403 for non-signed-in users' do
      get '/host/tournaments/new'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /host/tournaments' do
    it 'creates a new tournament' do
      sign_in user
      post '/host/tournaments', params: valid_attributes
      expect(response).to have_http_status(:found)
      expect(Tournament.count).to eq(1)
    end

    it 'creates a new tournament in JSON format' do
      sign_in user
      post '/host/tournaments.json', params: valid_attributes
      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['name']).to eq('Test Tournament')
    end

    it 'returns errors for invalid attributes' do
      sign_in user
      post '/host/tournaments', params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Tournament.count).to eq(0)
    end

    it 'returns errors for invalid attributes in JSON format' do
      sign_in user
      post '/host/tournaments.json', params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end

    it 'returns 403 for non-signed-in users' do
      post '/host/tournaments', params: valid_attributes
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 400 when required parameters are missing' do
      sign_in user
      post '/host/tournaments.json', params: { tournament: { location: 'Test' } } # Missing name and start_date
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /host/tournaments/:id/edit' do
    it 'returns a successful response' do
      sign_in user
      get "/host/tournaments/#{tournament.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'returns 403 for non-signed-in users' do
      get "/host/tournaments/#{tournament.id}/edit"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PUT /host/tournaments/:id' do
    it 'updates a tournament' do
      sign_in user
      put "/host/tournaments/#{tournament.id}", params: { tournament: { name: 'Updated Tournament' } }
      expect(response).to have_http_status(:found)
      expect(tournament.reload.name).to eq('Updated Tournament')
    end

    it 'updates a tournament in JSON format' do
      sign_in user
      put "/host/tournaments/#{tournament.id}.json", params: { tournament: { name: 'Updated Tournament' } }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['name']).to eq('Updated Tournament')
    end

    it 'returns errors for invalid attributes' do
      sign_in user
      put "/host/tournaments/#{tournament.id}", params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(tournament.reload.name).not_to be_nil
    end

    it 'returns errors for invalid attributes in JSON format' do
      sign_in user
      put "/host/tournaments/#{tournament.id}.json", params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end

    it 'returns 403 for non-signed-in users' do
      put "/host/tournaments/#{tournament.id}", params: { tournament: { name: 'Updated Tournament' } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 403 when user does not own the tournament' do
      another_user = create(:user)
      sign_in another_user
      put "/host/tournaments/#{tournament.id}", params: { tournament: { name: 'Updated Tournament' } }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns errors for incorrect parameter types' do
      sign_in user
      put "/host/tournaments/#{tournament.id}.json", params: { tournament: { start_date: 'invalid date' } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end
  end

  describe 'DELETE /host/tournaments/:id' do
    it 'deletes a tournament' do
      sign_in user
      delete "/host/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:found)
      expect(Tournament.count).to eq(0)
    end

    it 'deletes a tournament in JSON format' do
      sign_in user
      delete "/host/tournaments/#{tournament.id}.json"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(JSON.parse(response.body)['message']).to eq('Tournament deleted successfully!')
    end

    it 'returns 403 for non-signed-in users' do
      delete "/host/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 403 when user does not own the tournament' do
      another_user = create(:user)
      sign_in another_user
      delete "/host/tournaments/#{tournament.id}"
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "handle_internal_server_error" do
    it "returns a 500 error" do
      allow_any_instance_of(Host::TournamentsController).to receive(:index).and_raise("Test error")
      sign_in admin_user
      get "/host/tournaments"
      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['error']).to eq("Internal server error")
    end
  end

  describe "handle_parameter_missing" do
    it "returns a 400 error" do
      sign_in admin_user
      post "/host/tournaments", params: {}
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to eq("Invalid parameters")
    end
  end
end
