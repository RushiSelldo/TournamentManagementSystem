class MatchPolicy < ApplicationPolicy
  def create?
    user.hosted_tournaments.include?(record.tournament)
  end

  def update?
    create?  # If a user can create, they can also update
  end

  def destroy?
    create?  # If a user can create, they can also delete
  end
end
