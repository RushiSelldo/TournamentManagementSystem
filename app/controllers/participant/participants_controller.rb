module Participant
  class ParticipantsController < ApplicationController
    layout "participant"
    before_action :authenticate_user!
    before_action :set_tournament, only: [ :join, :leave, :matches, :teams ]
    before_action :authorize_participant

    def index
      @joined_tournaments = current_user.teams.includes(:tournament).map(&:tournament)
    end

    def join
      if current_user.teams.exists?(tournament: @tournament)
        redirect_to participant_tournaments_path, alert: "You have already joined this tournament."
      else
        team = current_user.teams.create(tournament: @tournament)
        if team.persisted?
          redirect_to participant_tournaments_path, notice: "Successfully joined the tournament!"
        else
          redirect_to participant_tournaments_path, alert: "Failed to join the tournament."
        end
      end
    end

    def leave
      team = current_user.teams.find_by(tournament: @tournament)
      if team
        team.destroy
        redirect_to participant_tournaments_path, notice: "Successfully left the tournament."
      else
        redirect_to participant_tournaments_path, alert: "You are not part of this tournament."
      end
    end

    def matches
      @matches = @tournament.matches
    end

    def teams
      @teams = @tournament.teams
    end

    private

    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def authorize_participant
      authorize :participant, policy_class: ParticipantPolicy
    end
  end
end
