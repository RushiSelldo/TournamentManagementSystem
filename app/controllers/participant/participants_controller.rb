module Participant
  class ParticipantsController < ApplicationController
    layout "participant"
    before_action :authenticate_user!
    before_action :set_tournament, only: [ :join, :leave ]
    before_action :set_participant_tournament, only: [ :matches, :teams ]
    before_action :authorize_participant

    # Dashboard: List tournaments the participant has joined
    def index
      @joined_tournaments = current_user.teams.includes(:tournament).map(&:tournament)
    end

    # List tournaments available for joining
    def available
      joined_ids = current_user.teams.pluck(:tournament_id)
      @available_tournaments = Tournament.where.not(id: joined_ids)
    end

    # Join a tournament: find a team with available spots or create one, then add the user
    def join
      if current_user.teams.exists?(tournament: @tournament)
        redirect_to participant_participants_path, alert: "You have already joined this tournament."
      else
        # Try to find an existing team with available spots (max team size is 5)
        team = @tournament.teams
                   .left_joins(:team_members)
                   .group("teams.id")
                   .having("COUNT(team_members.id) < ?", 5)
                   .first
        if team.nil?
          # If no team available, create a new team with a default name
          team = @tournament.teams.create(name: "Team #{SecureRandom.hex(3)}")
          unless team.persisted?
            redirect_to participant_participants_path, alert: "Failed to create a new team."
            return
          end
        end

        # Create a team member with default role "player" and set joined_at timestamp
        team_member = team.team_members.create(user: current_user, role: "player", joined_at: Time.current)
        if team_member.persisted?
          redirect_to participant_participants_path, notice: "Successfully joined the tournament in team #{team.name}!"
        else
          Rails.logger.error "TeamMember creation errors: #{team_member.errors.full_messages.join(', ')}"
          redirect_to participant_participants_path, alert: "Failed to join the tournament: #{team_member.errors.full_messages.join(', ')}"
        end
      end
    end


    # Leave a tournament: remove the user from the team
    def leave
      team = current_user.teams.find_by(tournament: @tournament)
      if team
        team_member = team.team_members.find_by(user: current_user)
        if team_member
          team_member.destroy
          # Optionally, delete the team if it becomes empty
          team.destroy if team.team_members.empty?
          redirect_to participant_participants_path, notice: "Successfully left the tournament."
        else
          redirect_to participant_participants_path, alert: "You are not a member of this team."
        end
      else
        redirect_to participant_participants_path, alert: "You are not part of this tournament."
      end
    end

    # Show matches for a tournament (user must be part of it)
    def matches
      @matches = @tournament.matches
    end

    # Show teams for a tournament (user must be part of it)
    def teams
      @teams = @tournament.teams
    end

    private

    # Finds the tournament for join/leave actions based on params[:id]
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    # Finds the tournament for matches and teams, ensuring the user is a participant
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
