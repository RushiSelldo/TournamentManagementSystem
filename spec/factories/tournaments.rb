# factories/tournaments.rb
FactoryBot.define do
  factory :tournament do
    name { "Test Tournament" }
    location { "New York" }
    start_date { Date.today }
    association :host, factory: :user
  end
end
