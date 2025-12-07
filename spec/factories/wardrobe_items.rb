FactoryBot.define do
  factory :wardrobe_item do
    association :user
    category { ["top", "bottom", "shoes"].sample }
    color { Faker::Color.color_name }
    
    after(:build) do |item|
      item.image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_image.jpg')),
        filename: 'sample_image.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end
