require 'rails_helper'

RSpec.describe Participant::ParticipantsController, type: :controller do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament) }
  let(:team) { create(:team, tournament: tournament) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns joined tournaments" do
      team.users << user
      get :index
      expect(assigns(:joined_tournaments)).to include(tournament)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe "GET #available" do
    it "assigns available tournaments" do
      joined_team = create(:team, tournament: tournament)
      joined_team.users << user

      other_tournament = create(:tournament)
      get :available
      expect(assigns(:available_tournaments)).to include(other_tournament)
      expect(assigns(:available_tournaments)).not_to include(tournament)
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:available)
    end
  end

  describe "POST #join" do
    let(:service) { double('ParticipantService') }

    context "when join is successful" do
      before do
        allow(ParticipantService).to receive(:new).with(user, tournament).and_return(service)
        allow(service).to receive(:join_tournament).and_return(success: true, team: team)
      end

      it "redirects to participants path with success notice" do
        post :join, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:notice]).to eq("Successfully joined the tournament in team #{team.name}!")
      end
    end

    context "when join fails" do
      before do
        allow(ParticipantService).to receive(:new).with(user, tournament).and_return(service)
        allow(service).to receive(:join_tournament).and_return(success: false, error: "Failed to join")
      end

      it "redirects to participants path with error alert" do
        post :join, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:alert]).to eq("Failed to join")
      end
    end
  end

  describe "DELETE #leave" do
    let(:service) { double('ParticipantService') }

    context "when leave is successful" do
      before do
        allow(ParticipantService).to receive(:new).with(user, tournament).and_return(service)
        allow(service).to receive(:leave_tournament).and_return(success: true)
      end

      it "redirects to participants path with success notice" do
        delete :leave, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:notice]).to eq("Successfully left the tournament.")
      end
    end

    context "when leave fails" do
      before do
        allow(ParticipantService).to receive(:new).with(user, tournament).and_return(service)
        allow(service).to receive(:leave_tournament).and_return(success: false, error: "Failed to leave")
      end

      it "redirects to participants path with error alert" do
        delete :leave, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:alert]).to eq("Failed to leave")
      end
    end
  end

  describe "GET #matches" do
    context "when user is part of the tournament" do
      let!(:match) { create(:match, tournament: tournament) }

      before do
        team.users << user
        get :matches, params: { id: tournament.id }
      end

      it "assigns tournament matches" do
        expect(assigns(:matches)).to include(match)
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:matches)
      end
    end

    context "when user is not part of the tournament" do
      it "redirects to participants path with error" do
        get :matches, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:alert]).to eq("Tournament not found or you are not part of it.")
      end
    end
  end

  describe "GET #teams" do
    context "when user is part of the tournament" do
      let!(:team) { create(:team, tournament: tournament) }

      before do
        team.users << user
        get :teams, params: { id: tournament.id }
      end

      it "assigns tournament teams" do
        expect(assigns(:teams)).to include(team)
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:teams)
      end
    end

    context "when user is not part of the tournament" do
      it "redirects to participants path with error" do
        get :teams, params: { id: tournament.id }
        expect(response).to redirect_to(participant_participants_path)
        expect(flash[:alert]).to eq("Tournament not found or you are not part of it.")
      end
    end
  end

  describe "private methods" do
    describe "#set_tournament" do
      it "sets the tournament instance variable" do
        controller.params[:id] = tournament.id
        controller.send(:set_tournament)
        expect(assigns(:tournament)).to eq(tournament)
      end
    end

    describe "#set_participant_tournament" do
      context "when user is part of the tournament" do
        it "sets the tournament instance variable" do
          team.users << user
          controller.params[:id] = tournament.id
          controller.send(:set_participant_tournament)
          expect(assigns(:tournament)).to eq(tournament)
        end
      end

      context "when user is not part of the tournament" do
        it "redirects to participants path with an error" do
          controller.params[:id] = tournament.id
          expect(controller).to receive(:redirect_to).with(participant_participants_path, alert: "Tournament not found or you are not part of it.")
          controller.send(:set_participant_tournament)
        end
      end
    end

    describe "#authorize_participant" do
      it "calls authorize with correct params" do
        expect(controller).to receive(:authorize).with(:participant, policy_class: ParticipantPolicy)
        controller.send(:authorize_participant)
      end
    end
  end
end
