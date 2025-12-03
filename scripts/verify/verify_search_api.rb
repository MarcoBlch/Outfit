require "net/http"
require "json"
require "uri"

BASE_URL = "http://localhost:3000"

def login(email, password)
  uri = URI("#{BASE_URL}/users/sign_in")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "application/json"
  request.body = { user: { email: email, password: password } }.to_json
  response = http.request(request)
  
  if response.code == "200"
    return response["Authorization"]
  else
    puts "Login failed: #{response.body}"
    return nil
  end
end

require "httparty"

def create_item(token, category, description)
  url = "#{BASE_URL}/wardrobe_items"
  
  # Ensure test image exists
  unless File.exist?("tmp/test_image.jpg")
    File.write("tmp/test_image.jpg", "dummy image content") 
  end

  response = HTTParty.post(
    url,
    headers: { "Authorization" => token },
    body: {
      wardrobe_item: {
        category: category,
        color: "blue",
        metadata: { description: description }.to_json, # Metadata might need to be JSON string in multipart
        image: File.open("tmp/test_image.jpg")
      }
    }
  )
  
  puts "Create Item Response: #{response.code}"
  puts "Create Item Body: #{response.body}"
  JSON.parse(response.body)
end

def update_embedding(item_id, description)
  # Manually generate and save embedding since job might fail on Vision API
  puts "Generating embedding for: '#{description}'..."
  embedding = EmbeddingService.new.embed(description)
  
  item = WardrobeItem.find(item_id)
  item.update!(embedding: embedding)
  puts "Embedding saved for item #{item_id}."
end

def search(token, query)
  uri = URI("#{BASE_URL}/wardrobe_items/search?query=#{URI.encode_www_form_component(query)}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = token
  
  response = http.request(request)
  
  if response.code != "200"
    puts "❌ Search Request Failed: #{response.code}"
    puts "Response Body: #{response.body}"
    return []
  end

  JSON.parse(response.body)
end

# Main Execution
begin
  puts "--- Starting Search API Verification ---"
  
  # 1. Login
  token = login("test@example.com", "password123")
  if token.nil?
    # Create user if not exists
    puts "Creating test user..."
    User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
    token = login("test@example.com", "password123")
  end
  puts "Logged in."

  # 2. Create Item
  description = "A vintage denim jacket with patches."
  item = create_item(token, "jackets", description)
  puts "Created item: #{item['id']}"

  # 3. Manually add embedding (bypassing job for test reliability)
  update_embedding(item['id'], description)

  # 4. Search
  query = "denim jacket"
  puts "Searching for: '#{query}'..."
  results = search(token, query)
  
  if results.is_a?(Array) && results.any? { |r| r['id'] == item['id'] }
    puts "✅ Success! Found item in search results."
    puts "Top result: #{results.first['category']} - #{results.first['metadata']}"
  else
    puts "❌ Error: Item not found in search results."
    puts "Results: #{results.inspect}"
  end

rescue => e
  puts "❌ Exception: #{e.message}"
  puts e.backtrace.join("\n")
end
