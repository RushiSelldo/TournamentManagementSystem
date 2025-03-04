# factories/team_members.rb
FactoryBot.define do
  factory :team_member do
    association :team
    association :user
    role { "player" }
    joined_at { Time.current }
  end
end
