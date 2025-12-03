# scripts/verify/verify_ai_job.rb
require_relative "../../config/environment"

puts "🚀 Starting AI Job Verification..."

# 1. Ensure we have a test user
user = User.find_by(email: "test@example.com")
unless user
  puts "❌ Test user not found. Please run the previous steps to create it."
  exit 1
end

# 2. Ensure we have a test image
image_path = Rails.root.join("tmp", "google_logo.png")
unless File.exist?(image_path)
  puts "⬇️ Downloading test image..."
  require "open-uri"
  File.open(image_path, "wb") do |file|
    file << URI.open("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png").read
  end
end

# 3. Create a WardrobeItem
puts "👕 Creating test WardrobeItem..."
item = user.wardrobe_items.build(
  category: nil, # Intentionally nil to simulate new upload
  color: nil
)
item.image.attach(io: File.open(image_path), filename: "google_logo.png", content_type: "image/png")
item.save!
puts "✅ Item created (ID: #{item.id})"

# Enable logger
Rails.logger = Logger.new(STDOUT)
ActiveJob::Base.logger = Logger.new(STDOUT)

# 4. Run the Job (Inline for immediate result)
puts "🧠 Running ImageAnalysisJob..."
begin
  ImageAnalysisJob.perform_now(item.id)
  
  # Reload item to get updated attributes
  item.reload
  
  puts "----------------------------------------"
  puts "🎉 Analysis Complete!"
  puts "Category: #{item.category}"
  puts "Color:    #{item.color}"
  puts "Tags:     #{item.metadata&.dig('tags')}"
  puts "Desc:     #{item.metadata&.dig('description')}"
  puts "----------------------------------------"

  if item.category.present? && item.metadata['tags'].present?
    puts "✅ Verification PASSED: Item was updated by AI."
  else
    puts "❌ Verification FAILED: Item was NOT updated."
  end

rescue => e
  puts "❌ Job Failed: #{e.message}"
  puts e.backtrace
end
