require 'rails_helper'

RSpec.describe Host::MatchesController, type: :request do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament, user: user) }
  let(:team1) { create(:team, tournament: tournament) }
  let(:team2) { create(:team, tournament: tournament) }
  let(:match) { create(:match, tournament: tournament, team_1: team1, team_2: team2) }
  let(:valid_attributes) do
    {
      match: {
        team_1_id: team1.id,
        team_2_id: team2.id,
        scheduled_at: Date.tomorrow,
        score_team_1: 1,
        score_team_2: 0
      },
      tournament_id: tournament.id
    }
  end
  let(:invalid_attributes) do
    {
      match: {
        team_1_id: nil,
        team_2_id: nil,
        scheduled_at: nil,
        score_team_1: nil,
        score_team_2: nil
      },
      tournament_id: tournament.id
    }
  end

  before { sign_in user }

  describe 'GET /host/tournaments/:tournament_id/matches/new' do
    it 'returns a successful response' do
      get "/host/tournaments/#{tournament.id}/matches/new"
      expect(response).to have_http_status(:ok)
    end

    it 'renders the new template' do
      get "/host/tournaments/#{tournament.id}/matches/new"
      expect(response).to render_template(:new)
    end

    it 'redirects to root path if tournament is not found' do
      get "/host/tournaments/999/matches/new"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Tournament not found.")
    end
  end

  describe 'POST /host/tournaments/:tournament_id/matches' do
    it 'creates a new match with valid attributes' do
      post "/host/tournaments/#{tournament.id}/matches", params: valid_attributes
      expect(response).to have_http_status(:found)
      expect(Match.count).to eq(1)
      expect(flash[:notice]).to eq("Match created successfully.")
    end

    it 'renders new template with unprocessable entity status with invalid attributes' do
      post "/host/tournaments/#{tournament.id}/matches", params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq("Team 1 must exist, Team 2 must exist, Scheduled at can't be blank")
    end

    it 'redirects to root path if tournament is not found' do
      post "/host/tournaments/999/matches", params: valid_attributes
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Tournament not found.")
    end

    it 'handles missing parameters with 422 status' do
      post "/host/tournaments/#{tournament.id}/matches", params: { tournament_id: tournament.id }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
      expect(flash[:alert]).to eq("Invalid match parameters.")
    end
  end

  describe 'GET /host/tournaments/:tournament_id/matches/:id/edit' do
    it 'returns a successful response' do
      get "/host/tournaments/#{tournament.id}/matches/#{match.id}/edit"
      expect(response).to have_http_status(:ok)
    end

    it 'renders the edit template' do
      get "/host/tournaments/#{tournament.id}/matches/#{match.id}/edit"
      expect(response).to render_template(:edit)
    end

    it 'redirects to root path if tournament is not found' do
      get "/host/tournaments/999/matches/#{match.id}/edit"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Tournament not found.")
    end

    it 'redirects to tournament path if match is not found' do
      get "/host/tournaments/#{tournament.id}/matches/999/edit"
      expect(response).to redirect_to(host_tournament_path(tournament))
      expect(flash[:alert]).to eq("Match not found.")
    end
  end

  describe 'PUT /host/tournaments/:tournament_id/matches/:id' do
    it 'updates a match with valid attributes' do
      put "/host/tournaments/#{tournament.id}/matches/#{match.id}", params: valid_attributes
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq("Match updated successfully.")
      expect(match.reload.scheduled_at).to eq(valid_attributes[:match][:scheduled_at])
    end

    it 'renders edit template with unprocessable entity status with invalid attributes' do
      put "/host/tournaments/#{tournament.id}/matches/#{match.id}", params: invalid_attributes
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:edit)
      expect(flash[:alert]).to eq("Team 1 must exist, Team 2 must exist, Scheduled at can't be blank")
    end

    it 'redirects to root path if tournament is not found' do
      put "/host/tournaments/999/matches/#{match.id}", params: valid_attributes
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Tournament not found.")
    end

    it 'redirects to tournament path if match is not found' do
      put "/host/tournaments/#{tournament.id}/matches/999", params: valid_attributes
      expect(response).to redirect_to(host_tournament_path(tournament))
      expect(flash[:alert]).to eq("Match not found.")
    end
  end

  describe 'DELETE /host/tournaments/:tournament_id/matches/:id' do
    it 'deletes a match' do
      delete "/host/tournaments/#{tournament.id}/matches/#{match.id}"
      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq("Match deleted successfully.")
      expect(Match.count).to eq(0)
    end

    it 'redirects to root path if tournament is not found' do
      delete "/host/tournaments/999/matches/#{match.id}"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Tournament not found.")
    end

    it 'redirects to tournament path if match is not found' do
      delete "/host/tournaments/#{tournament.id}/matches/999"
      expect(response).to redirect_to(host_tournament_path(tournament))
      expect(flash[:alert]).to eq("Match not found.")
    end

    it 'handles StandardError' do
      allow_any_instance_of(Host::MatchesController).to receive(:destroy).and_raise("StandardError")
      delete "/host/tournaments/#{tournament.id}/matches/#{match.id}"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Something went wrong. Please try again later.")
    end
  end

  describe 'Authorization' do
    let(:another_user) { create(:user) }
    let(:another_tournament) { create(:tournament, user: another_user) }
    let(:another_team1) { create(:team, tournament: another_tournament) }
    let(:another_team2) { create(:team, tournament: another_tournament) }
    let(:another_match) { create(:match, tournament: another_tournament, team_1: another_team1, team_2: another_team2) }

    before { sign_in another_user }

    it 'blocks unauthorized access to new' do
      get "/host/tournaments/#{tournament.id}/matches/new"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it 'blocks unauthorized access to create' do
      post "/host/tournaments/#{tournament.id}/matches", params: valid_attributes
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it 'blocks unauthorized access to edit' do
      get "/host/tournaments/#{tournament.id}/matches/#{match.id}/edit"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it 'blocks unauthorized access to update' do
      put "/host/tournaments/#{tournament.id}/matches/#{match.id}", params: valid_attributes
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end

    it 'blocks unauthorized access to destroy' do
      delete "/host/tournaments/#{tournament.id}/matches/#{match.id}"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to perform this action.")
    end
  end
end
