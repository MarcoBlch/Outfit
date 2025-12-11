FactoryBot.define do
  factory :outfit_suggestion do
    association :user
    context { Faker::Lorem.sentence }
    status { "completed" }
    validated_suggestions { [] }
    suggestions_count { 0 }
    response_time_ms { 1000 }
    api_cost { 0.01 }

    trait :pending do
      status { "pending" }
    end

    trait :failed do
      status { "failed" }
      error_message { "Something went wrong" }
    end

    trait :with_suggestions do
      validated_suggestions do
        [
          {
            rank: 1,
            confidence: 0.95,
            reasoning: "Professional outfit",
            items: []
          }
        ]
      end
      suggestions_count { 1 }
    end
  end
end
