require "dotenv/load"
require "httparty"
require "googleauth"
require "json"

begin
  project_id = ENV["GOOGLE_CLOUD_PROJECT"]
  location = ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1"
  # Updated to use current model (gemini-1.0 was retired in September 2025)
  model_id = "gemini-2.5-flash"
  
  puts "Testing Text Generation with #{model_id}..."
  
  authorizer = Google::Auth.get_application_default
  token = authorizer.fetch_access_token!["access_token"]
  
  endpoint = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/#{model_id}:generateContent"
  
  body = {
    contents: [{ role: "user", parts: [{ text: "Hello, are you working?" }] }]
  }
  
  response = HTTParty.post(
    endpoint,
    headers: {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    },
    body: body.to_json
  )
  
  puts "Response Code: #{response.code}"
  puts response.body

rescue => e
  puts "Exception: #{e.message}"
end
