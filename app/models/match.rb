class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :team_1, class_name: "Team", foreign_key: "team_1_id"
  belongs_to :team_2, class_name: "Team", foreign_key: "team_2_id"

  validates :scheduled_at, presence: true
  validates :team_1_id, presence: true
  validates :team_2_id, presence: true
  validates :score_team_1, numericality: { greater_than_or_equal_to: 0 }
  validates :score_team_2, numericality: { greater_than_or_equal_to: 0 }
  validate :teams_must_be_different

  private

  def teams_must_be_different
    if team_1_id == team_2_id
      errors.add(:team_2_id, "must be different from Team 1")
    end
  end
end
