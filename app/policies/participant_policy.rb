class ParticipantPolicy < ApplicationPolicy
  def index?
    user.role == "participant"
  end

  def available?
    user.role == "participant"
  end

  def join?
    user.role == "participant"
  end

  def leave?
    user.role == "participant"
  end

  def matches?
    user.role == "participant"
  end

  def teams?
    user.role == "participant"
  end
end
