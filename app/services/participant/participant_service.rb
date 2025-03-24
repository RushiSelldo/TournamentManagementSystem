module Participant
  class ParticipantService
    def initialize(user, tournament)
      @user = user
      @tournament = tournament
    end


    def join_tournament
      return { success: false, error: "You have already joined this tournament." } if already_joined?

      team = find_or_create_team
      return { success: false, error: "Failed to create a new team." } unless team

      team_member = team.team_members.create(user: @user, role: "player", joined_at: Time.current)
      if team_member.persisted?
        { success: true, team: team }
      else
        { success: false, error: team_member.errors.full_messages.join(", ") }
      end
    end


    def leave_tournament
      team = @user.teams.find_by(tournament: @tournament)
      return { success: false, error: "You are not part of this tournament." } unless team

      team_member = team.team_members.find_by(user: @user)
      return { success: false, error: "You are not a member of this team." } unless team_member

      if team_member.destroy
        team.destroy if team.team_members.empty?
        { success: true }
      else
        { success: false, error: "Failed to leave the tournament." }
      end
    end

    private

    def already_joined?
      @user.teams.exists?(tournament: @tournament)
    end

    def find_or_create_team
      # team = @tournament.teams
      #           .left_joins(:team_members)
      #           .group("teams.id")
      #           .having("COUNT(team_members.id) < ?", 5)
      #           .first

      # if team.nil?
      #   team = @tournament.teams.create(name: "Team #{SecureRandom.hex(3)}")
      #   return nil unless team.persisted?
      # end

      # team
      team = @tournament.teams.create(name: "Team #{SecureRandom.hex(3)}")
      return nil unless team.persisted?

      team
    end
  end
end
