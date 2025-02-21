class TournamentPolicy < ApplicationPolicy
  def new?
    user&.host? # Only hosts can access the new tournament form
  end

  def create?
    user&.host? # Only hosts can create tournaments
  end

  def update?
    user&.admin? || record.host == user # Admins or the host can update
  end

  def destroy?
    user&.admin? || record.host == user # Admins or the host can delete
  end

  class Scope < Scope
    def resolve
      scope.all # Return all tournaments (modify if needed)
    end
  end
end
