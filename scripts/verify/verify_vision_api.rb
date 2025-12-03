# verify_vision_api.rb
require "dotenv/load"
require_relative "../../config/environment"

begin
  puts "--- Starting Vision API Verification ---"

  # 1. Check Service Initialization
  puts "Initializing Service..."
  service = ImageAnalysisService.new
  puts "Service Initialized."

  # 2. Use an existing image
  image_path = 'tmp/google_logo.png'
  unless File.exist?(image_path)
    puts "❌ Error: Test image not found at #{image_path}"
    exit 1
  end

  # 3. Call Analyze
  puts "Calling analyze with #{image_path}..."
  result = service.analyze(image_path)
  
  puts "Analysis Result:"
  puts JSON.pretty_generate(result)

  if result['category'].present?
    puts "✅ Success! Category detected: #{result['category']}"
  else
    puts "❌ Failed: No category detected."
  end

rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace
end
