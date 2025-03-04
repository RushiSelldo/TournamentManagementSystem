# factories/matches.rb
FactoryBot.define do
  factory :match do
    association :tournament
    association :team_1, factory: :team
    association :team_2, factory: :team
    scheduled_at { Time.current + 1.day }
    score_team_1 { 0 }
    score_team_2 { 0 }

    # Ensure that team_1 and team_2 are different
    after(:build) do |match|
      match.team_2 = create(:team, tournament: match.tournament) if match.team_1 == match.team_2
    end
  end
end
