FactoryBot.define do
  factory :product_recommendation do
    association :outfit_suggestion

    category { %w[blazer dress-pants loafers shirt sweater].sample }
    description { Faker::Commerce.product_name }
    color_preference { %w[navy black gray white blue brown].sample }
    style_notes { "Professional and modern style" }
    reasoning { "Would complete professional outfits with existing wardrobe items" }
    priority { :medium }
    budget_range { :mid_range }
    ai_image_status { :pending }

    views { 0 }
    clicks { 0 }
    conversions { 0 }
    revenue_earned { 0.0 }

    affiliate_products { [] }

    trait :pending_image do
      ai_image_status { :pending }
      ai_image_url { nil }
    end

    trait :generating_image do
      ai_image_status { :generating }
    end

    trait :with_image do
      ai_image_status { :completed }
      ai_image_url { "https://replicate.delivery/test-image-#{SecureRandom.hex(8)}.png" }
      ai_image_cost { 0.0025 }
    end

    trait :failed_image do
      ai_image_status { :failed }
      ai_image_error { "Image generation failed: API error" }
    end

    trait :high_priority do
      priority { :high }
    end

    trait :low_priority do
      priority { :low }
    end

    trait :budget do
      budget_range { :budget }
    end

    trait :luxury do
      budget_range { :luxury }
    end

    trait :with_products do
      affiliate_products do
        [
          {
            name: Faker::Commerce.product_name,
            price: Faker::Commerce.price,
            url: Faker::Internet.url,
            image_url: Faker::LoremFlickr.image
          }
        ]
      end
    end

    trait :with_amazon_products do
      affiliate_products do
        [
          {
            "title" => "Classic Black Dress Pants Slim Fit",
            "price" => "49.99",
            "currency" => "USD",
            "url" => "https://www.amazon.com/dp/B08ABC123?tag=test-tag",
            "image_url" => "https://m.media-amazon.com/images/I/test-image.jpg",
            "rating" => 4.5,
            "review_count" => 1234,
            "asin" => "B08ABC123"
          },
          {
            "title" => "Professional Wool Blend Dress Pants",
            "price" => "79.99",
            "currency" => "USD",
            "url" => "https://www.amazon.com/dp/B08XYZ789?tag=test-tag",
            "image_url" => "https://m.media-amazon.com/images/I/test-image-2.jpg",
            "rating" => 4.7,
            "review_count" => 856,
            "asin" => "B08XYZ789"
          }
        ]
      end
    end

    trait :with_analytics do
      views { rand(100..1000) }
      clicks { rand(10..100) }
      conversions { rand(1..10) }
      revenue_earned { rand(10.0..100.0).round(2) }
    end
  end
end
