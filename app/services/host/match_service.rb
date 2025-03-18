module Host
  class MatchService
    def initialize(tournament, params = {})
      @tournament = tournament
      @params = params
    end

    def list_matches
      @tournament.matches.order(scheduled_at: :asc)
    end

    def find_match(id)
      @tournament.matches.find(id)
    end

    def create_match
      match = @tournament.matches.new(@params)

      if match.save
        { success: true, match: match }
      else
        { success: false, errors: match.errors.full_messages }
      end
    end

    def update_match(match)
      if match.update(@params)
        { success: true, match: match }
      else
        { success: false, errors: match.errors.full_messages }
      end
    end

    def delete_match(match)
      if match.destroy
        { success: true }
      else
        { success: false, errors: match.errors.full_messages }
      end
    end
  end
end
