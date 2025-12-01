FactoryBot.define do
  factory :outfit do
    user { nil }
    name { "MyString" }
    metadata { "" }
    last_worn_at { "2025-12-02 00:13:13" }
    favorite { false }
  end
end
