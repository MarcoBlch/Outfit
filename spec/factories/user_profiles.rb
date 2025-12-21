FactoryBot.define do
  factory :user_profile do
    association :user
    presentation_style { :masculine }
    style_preference { :business_casual }
    body_type { :athletic }
    age_range { "25-34" }
    location { "San Francisco, CA" }
    metadata { { "favorite_colors" => ["blue", "black", "gray"] } }

    trait :feminine do
      presentation_style { :feminine }
    end

    trait :androgynous do
      presentation_style { :androgynous }
    end

    trait :casual_style do
      style_preference { :casual }
    end

    trait :formal_style do
      style_preference { :formal }
    end

    trait :minimalist_style do
      style_preference { :minimalist }
    end

    trait :complete do
      presentation_style { :masculine }
      style_preference { :business_casual }
      body_type { :athletic }
      age_range { "25-34" }
      location { "San Francisco, CA" }
      metadata { { "favorite_colors" => ["navy", "charcoal", "white", "olive"] } }
    end

    trait :incomplete do
      presentation_style { nil }
      style_preference { nil }
      body_type { nil }
      age_range { nil }
      location { nil }
      metadata { {} }
    end
  end
end
