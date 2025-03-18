module Host
  class TournamentService
    def initialize(user, params = {})
      @user = user
      @params = params
    end

    def count
      Tournament.count
    end

    def list_tournaments
      Tournament.order(created_at: :desc)
    end

    def find_tournament(id)
      Tournament.find(id)
    end

    def create_tournament
      tournament = @user.hosted_tournaments.build(@params)

      if tournament.save
        { success: true, tournament: tournament }
      else
        { success: false, errors: tournament.errors.full_messages }
      end
    end

    def update_tournament(tournament)
      if tournament.update(@params)
        { success: true, tournament: tournament }
      else
        { success: false, errors: tournament.errors.full_messages }
      end
    end

    def delete_tournament(tournament)
      if tournament.destroy
        { success: true }
      else
        { success: false, errors: tournament.errors.full_messages }
      end
    end
  end
end
