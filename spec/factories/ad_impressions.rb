FactoryBot.define do
  factory :ad_impression do
    user { nil }
    placement { "MyString" }
    clicked { false }
    revenue { "9.99" }
    created_at { "2025-12-11 11:30:48" }
  end
end
