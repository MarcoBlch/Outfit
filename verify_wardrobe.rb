
begin
  # Cleanup previous test data
  User.where(email: 'test_wardrobe_final@example.com').destroy_all
  
  user = User.create!(email: 'test_wardrobe_final@example.com', password: 'password', jti: 'test_jti_final')
  item = user.wardrobe_items.create!(
    category: 'test',
    embedding: "[#{Array.new(768, 0.1).join(',')}]",
    image: { io: File.open('tmp/test_image.jpg'), filename: 'test_image.jpg' }
  )
  puts 'Item created: ' + item.persisted?.to_s
  puts 'Embedding class: ' + item.embedding.class.name
  
  # Test nearest neighbors
  neighbors = WardrobeItem.nearest_neighbors(Array.new(768, 0.1))
  puts 'Neighbors count: ' + neighbors.count.to_s
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace
end
