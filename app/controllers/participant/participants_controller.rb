module Participant
  class ParticipantsController < ApplicationController
    layout "participant"
    before_action :authenticate_user!
    before_action :set_tournament, only: [ :join, :leave ]
    before_action :set_participant_tournament, only: [ :matches, :teams ]
    before_action :authorize_participant

    def index
      @joined_tournaments = current_user.teams.includes(:tournament).map(&:tournament)
    end

    def available
      joined_ids = current_user.teams.pluck(:tournament_id)
      @available_tournaments = Tournament.where.not(id: joined_ids)
    end

    def join
      service = ParticipantService.new(current_user, @tournament)
      result = service.join_tournament

      if result[:success]
        redirect_to participant_participants_path, notice: "Successfully joined the tournament in team #{result[:team].name}!"
      else
        redirect_to participant_participants_path, alert: result[:error]
      end
    end

    def leave
      service = ParticipantService.new(current_user, @tournament)
      result = service.leave_tournament

      if result[:success]
        redirect_to participant_participants_path, notice: "Successfully left the tournament."
      else
        redirect_to participant_participants_path, alert: result[:error]
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

    def set_participant_tournament
      @tournament = current_user.teams.includes(:tournament).map(&:tournament).find_by(id: params[:id])
      unless @tournament
        redirect_to participant_participants_path, alert: "Tournament not found or you are not part of it."
      end
    end

    def authorize_participant
      authorize :participant, policy_class: ParticipantPolicy
    end
  end
end
