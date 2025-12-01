
require 'net/http'
require 'json'
require 'uri'

# Setup
base_url = 'http://localhost:3000'
email = "api_test_#{Time.now.to_i}@example.com"
password = 'password123'

# 1. Register User
puts "\n--- Registering User ---"
uri = URI("#{base_url}/users")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
request.body = { user: { email: email, password: password, password_confirmation: password } }.to_json
response = http.request(request)
puts "Response Code: #{response.code}"

if response.code != '201' && response.code != '200'
  puts "Registration failed: #{response.body}"
  exit 1
end

# Extract Token
token = response['Authorization']
puts "Token received: #{token ? 'Yes' : 'No'}"

# 2. Create Wardrobe Item (Multipart)
puts "\n--- Creating Wardrobe Item ---"
uri = URI("#{base_url}/wardrobe_items")
request = Net::HTTP::Post.new(uri.path)
request['Authorization'] = token
form_data = [
  ['wardrobe_item[category]', 't-shirt'],
  ['wardrobe_item[color]', 'blue'],
  ['wardrobe_item[image]', File.open('tmp/test_image.jpg')]
]
request.set_form(form_data, 'multipart/form-data')
response = http.request(request)
puts "Response Code: #{response.code}"
puts "Response Body: #{response.body}"

if response.code != '201'
  puts "Creation failed"
  exit 1
end

item_id = JSON.parse(response.body)['id']
puts "Item ID: #{item_id}"

# 3. List Items
puts "\n--- Listing Items ---"
uri = URI("#{base_url}/wardrobe_items")
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"
items = JSON.parse(response.body)
puts "Items count: #{items.size}"

# 4. Show Item
puts "\n--- Showing Item ---"
uri = URI("#{base_url}/wardrobe_items/#{item_id}")
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"

# 5. Delete Item
puts "\n--- Deleting Item ---"
uri = URI("#{base_url}/wardrobe_items/#{item_id}")
request = Net::HTTP::Delete.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"
