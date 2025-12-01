
require 'net/http'
require 'json'
require 'uri'

# Setup
base_url = 'http://localhost:3000'
email = "outfit_test_#{Time.now.to_i}@example.com"
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

token = response['Authorization']

# 2. Create Wardrobe Items
puts "\n--- Creating Wardrobe Items ---"
item_ids = []
2.times do |i|
  uri = URI("#{base_url}/wardrobe_items")
  request = Net::HTTP::Post.new(uri.path)
  request['Authorization'] = token
  form_data = [
    ['wardrobe_item[category]', "item_#{i}"],
    ['wardrobe_item[image]', File.open('tmp/test_image.jpg')]
  ]
  request.set_form(form_data, 'multipart/form-data')
  response = http.request(request)
  item_ids << JSON.parse(response.body)['id']
end
puts "Item IDs: #{item_ids}"

# 3. Create Outfit
puts "\n--- Creating Outfit ---"
uri = URI("#{base_url}/outfits")
request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => token})
request.body = {
  outfit: {
    name: 'Summer Look',
    outfit_items_attributes: [
      { wardrobe_item_id: item_ids[0], position_x: 10.0, position_y: 20.0, z_index: 1 },
      { wardrobe_item_id: item_ids[1], position_x: 50.0, position_y: 60.0, z_index: 2 }
    ]
  }
}.to_json
response = http.request(request)
puts "Response Code: #{response.code}"
puts "Response Body: #{response.body}"

if response.code != '201'
  puts "Outfit creation failed"
  exit 1
end

outfit_id = JSON.parse(response.body)['id']
puts "Outfit ID: #{outfit_id}"

# 4. List Outfits
puts "\n--- Listing Outfits ---"
uri = URI("#{base_url}/outfits")
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"
outfits = JSON.parse(response.body)
puts "Outfits count: #{outfits.size}"

# 5. Show Outfit
puts "\n--- Showing Outfit ---"
uri = URI("#{base_url}/outfits/#{outfit_id}")
request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"
outfit_data = JSON.parse(response.body)
puts "Items in outfit: #{outfit_data['outfit_items'].size}"

# 6. Update Outfit (Remove one item)
puts "\n--- Updating Outfit ---"
item_to_remove_id = outfit_data['outfit_items'].first['id']
uri = URI("#{base_url}/outfits/#{outfit_id}")
request = Net::HTTP::Put.new(uri.path, {'Content-Type' => 'application/json', 'Authorization' => token})
request.body = {
  outfit: {
    name: 'Updated Look',
    outfit_items_attributes: [
      { id: item_to_remove_id, _destroy: true }
    ]
  }
}.to_json
response = http.request(request)
puts "Response Code: #{response.code}"
updated_outfit = JSON.parse(response.body)
puts "Updated items count: #{updated_outfit['outfit_items'].size}"

# 7. Delete Outfit
puts "\n--- Deleting Outfit ---"
uri = URI("#{base_url}/outfits/#{outfit_id}")
request = Net::HTTP::Delete.new(uri.path)
request['Authorization'] = token
response = http.request(request)
puts "Response Code: #{response.code}"
