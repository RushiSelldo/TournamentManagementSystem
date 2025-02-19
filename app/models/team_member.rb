class TeamMember < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :role, presence: true, inclusion: { in: %w[player captain coach] }
  validates :joined_at, presence: true
end
