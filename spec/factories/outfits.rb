FactoryBot.define do
  factory :outfit do
    association :user
    name { Faker::Lorem.words(number: 2).join(' ') }
    last_worn_at { Time.current }
    favorite { false }
  end
end
