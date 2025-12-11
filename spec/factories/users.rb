FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    subscription_tier { 'free' }
    admin { false }

    trait :admin do
      admin { true }
    end

    trait :free_tier do
      subscription_tier { 'free' }
    end

    trait :premium do
      subscription_tier { 'premium' }
    end

    trait :pro do
      subscription_tier { 'pro' }
    end
  end
end
