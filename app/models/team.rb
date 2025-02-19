class Team < ApplicationRecord
  belongs_to :tournament
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :matches_as_team_1, class_name: "Match", foreign_key: "team_1_id"
  has_many :matches_as_team_2, class_name: "Match", foreign_key: "team_2_id"

  validates :name, presence: true, uniqueness: { scope: :tournament_id }
end
