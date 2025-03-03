FactoryBot.define do
  factory :tournament do
    sequence(:name) { |n| "Tournament #{n}" }
    location { "Some Location" }
    start_date { Date.today + 5 }
  end
end
