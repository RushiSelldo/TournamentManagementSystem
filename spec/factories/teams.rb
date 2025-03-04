# factories/teams.rb
FactoryBot.define do
  factory :team do
    name { "Test Team" }
    association :tournament
  end
end
