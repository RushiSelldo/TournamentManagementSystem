class TournamentPolicy < ApplicationPolicy
  def index?
    true # Everyone can view tournaments
  end

  def show?
    true # Everyone can view a specific tournament
  end

  def create?
    user.present? && user.role == "host" # Only hosts can create tournaments
  end

  def update?
    user.present? && user.role == "host" && record.host == user # Only the host can update
  end

  def destroy?
    user.present? && user.role == "host" && record.host == user # Only the host can delete
  end

  def my_tournaments?
    user.present? && user.role =="host"
  end

  def count?
    true # Anyone can fetch tournament count
  end
end
