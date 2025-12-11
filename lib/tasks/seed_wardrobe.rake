namespace :wardrobe do
  desc "Seed test wardrobes with sample fashion images (no AI tokens used)"
  task seed_test_data: :environment do
    require 'open-uri'
    require 'fileutils'

    puts "🎨 Starting wardrobe seed process..."

    # Sample fashion images from free sources (placeholder URLs - replace with actual free sources)
    # Sources: Unsplash, Pixabay, Pexels (all offer free commercial use images)
    SAMPLE_ITEMS = [
      # Tops
      { category: 'top', color: 'white', url: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800' },
      { category: 'top', color: 'black', url: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800' },
      { category: 'shirt', color: 'blue', url: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800' },
      { category: 'blouse', color: 'pink', url: 'https://images.unsplash.com/photo-1624206112918-f140f087f9b5?w=800' },

      # Bottoms
      { category: 'jeans', color: 'blue', url: 'https://images.unsplash.com/photo-1542272454315-7a4b2f396b0c?w=800' },
      { category: 'pants', color: 'black', url: 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800' },
      { category: 'skirt', color: 'red', url: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800' },
      { category: 'shorts', color: 'khaki', url: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800' },

      # Dresses
      { category: 'dress', color: 'floral', url: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800' },
      { category: 'dress', color: 'black', url: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800' },

      # Outerwear
      { category: 'jacket', color: 'leather', url: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800' },
      { category: 'blazer', color: 'navy', url: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800' },
      { category: 'coat', color: 'camel', url: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800' },

      # Shoes
      { category: 'sneakers', color: 'white', url: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800' },
      { category: 'heels', color: 'black', url: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800' },
      { category: 'boots', color: 'brown', url: 'https://images.unsplash.com/photo-1605812860427-4024433a70fd?w=800' },

      # Accessories
      { category: 'bag', color: 'brown', url: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=800' },
      { category: 'hat', color: 'beige', url: 'https://images.unsplash.com/photo-1521369909029-2afed882baee?w=800' },
      { category: 'scarf', color: 'multicolor', url: 'https://images.unsplash.com/photo-1601924287388-2d3e815c785d?w=800' },
    ]

    # Get or create test user
    user = User.find_or_create_by!(email: 'test@example.com') do |u|
      u.password = 'password123'
      u.password_confirmation = 'password123'
    end

    puts "👤 Using test user: #{user.email}"

    # Create temporary directory for downloads
    temp_dir = Rails.root.join('tmp', 'seed_images')
    FileUtils.mkdir_p(temp_dir)

    success_count = 0
    error_count = 0

    SAMPLE_ITEMS.each_with_index do |item_data, index|
      begin
        print "📦 Creating #{item_data[:category]} (#{item_data[:color]})... "

        # Download image
        temp_file = temp_dir.join("item_#{index}.jpg")
        URI.open(item_data[:url]) do |image|
          File.open(temp_file, 'wb') do |file|
            file.write(image.read)
          end
        end

        # Create wardrobe item
        item = user.wardrobe_items.create!(
          category: item_data[:category],
          color: item_data[:color],
          tags: ['test', 'seed-data']
        )

        # Attach image
        item.image.attach(
          io: File.open(temp_file),
          filename: "#{item_data[:category]}_#{item_data[:color]}.jpg",
          content_type: 'image/jpeg'
        )

        puts "✅"
        success_count += 1

      rescue => e
        puts "❌ Error: #{e.message}"
        error_count += 1
      end

      # Be nice to image servers
      sleep 0.5
    end

    # Cleanup
    FileUtils.rm_rf(temp_dir)

    puts "\n" + "="*50
    puts "✨ Seed complete!"
    puts "Successfully created: #{success_count} items"
    puts "Errors: #{error_count}" if error_count > 0
    puts "User: #{user.email}"
    puts "Total wardrobe items: #{user.wardrobe_items.count}"
    puts "="*50
  end

  desc "Seed multiple test users with diverse wardrobes"
  task seed_multiple_users: :environment do
    require 'open-uri'
    require 'fileutils'

    puts "👥 Creating multiple test users with wardrobes..."

    # Define user profiles with different style preferences
    USER_PROFILES = [
      { email: 'casual_user@test.com', style: 'casual', items_count: 15 },
      { email: 'formal_user@test.com', style: 'formal', items_count: 20 },
      { email: 'sporty_user@test.com', style: 'sporty', items_count: 12 },
      { email: 'minimal_user@test.com', style: 'minimalist', items_count: 10 },
    ]

    # Curated items by style
    STYLE_ITEMS = {
      casual: [
        { category: 'jeans', color: 'blue', url: 'https://images.unsplash.com/photo-1542272454315-7a4b2f396b0c?w=800' },
        { category: 'top', color: 'white', url: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800' },
        { category: 'sneakers', color: 'white', url: 'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=800' },
      ],
      formal: [
        { category: 'blazer', color: 'navy', url: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800' },
        { category: 'dress', color: 'black', url: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800' },
        { category: 'heels', color: 'black', url: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800' },
      ],
      sporty: [
        { category: 'joggers', color: 'black', url: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800' },
        { category: 'hoodie', color: 'gray', url: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800' },
        { category: 'sneakers', color: 'black', url: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800' },
      ],
      minimalist: [
        { category: 'top', color: 'black', url: 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800' },
        { category: 'pants', color: 'black', url: 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800' },
        { category: 'coat', color: 'camel', url: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800' },
      ]
    }

    temp_dir = Rails.root.join('tmp', 'seed_images')
    FileUtils.mkdir_p(temp_dir)

    USER_PROFILES.each do |profile|
      puts "\n👤 Creating user: #{profile[:email]} (#{profile[:style]} style)"

      user = User.find_or_create_by!(email: profile[:email]) do |u|
        u.password = 'password123'
        u.password_confirmation = 'password123'
      end

      # Create user profile
      user.create_user_profile!(
        style_preference: profile[:style],
        gender: 'female',
        age: 28
      ) unless user.user_profile

      items = STYLE_ITEMS[profile[:style].to_sym] * (profile[:items_count] / 3 + 1)
      items = items.first(profile[:items_count])

      items.each_with_index do |item_data, index|
        begin
          temp_file = temp_dir.join("#{profile[:style]}_#{index}.jpg")

          URI.open(item_data[:url]) do |image|
            File.open(temp_file, 'wb') { |file| file.write(image.read) }
          end

          item = user.wardrobe_items.create!(
            category: item_data[:category],
            color: item_data[:color],
            tags: [profile[:style], 'test-data']
          )

          item.image.attach(
            io: File.open(temp_file),
            filename: "#{item_data[:category]}.jpg",
            content_type: 'image/jpeg'
          )

          print "."
          sleep 0.3

        rescue => e
          print "x"
        end
      end

      puts " ✅ Created #{user.wardrobe_items.count} items"
    end

    FileUtils.rm_rf(temp_dir)
    puts "\n✨ All test users created successfully!"
  end

  desc "Use local sample images (no downloads needed)"
  task seed_from_local: :environment do
    puts "📁 Seeding from local sample images..."

    sample_images_dir = Rails.root.join('public', 'sample_images')

    unless Dir.exist?(sample_images_dir)
      puts "❌ Sample images directory not found: #{sample_images_dir}"
      puts "💡 Create this directory and add sample fashion images, then run again."
      exit
    end

    user = User.find_or_create_by!(email: 'test@example.com') do |u|
      u.password = 'password123'
      u.password_confirmation = 'password123'
    end

    # Category detection based on filename
    CATEGORY_KEYWORDS = {
      'top' => ['tshirt', 'top', 'shirt', 'blouse'],
      'pants' => ['pants', 'trousers', 'jeans'],
      'dress' => ['dress'],
      'jacket' => ['jacket', 'coat', 'blazer'],
      'shoes' => ['shoes', 'sneakers', 'heels', 'boots'],
      'accessories' => ['bag', 'hat', 'scarf', 'belt']
    }

    Dir.glob(sample_images_dir.join('*.{jpg,jpeg,png}')).each do |image_path|
      filename = File.basename(image_path, '.*').downcase

      # Detect category from filename
      category = CATEGORY_KEYWORDS.find { |cat, keywords| keywords.any? { |kw| filename.include?(kw) } }&.first || 'other'

      # Detect color from filename (simple heuristic)
      color = %w[black white blue red green yellow pink gray brown].find { |c| filename.include?(c) } || 'mixed'

      item = user.wardrobe_items.create!(
        category: category,
        color: color,
        tags: ['local', 'test']
      )

      item.image.attach(
        io: File.open(image_path),
        filename: File.basename(image_path),
        content_type: "image/#{File.extname(image_path)[1..-1]}"
      )

      puts "✅ Added: #{filename} (#{category}, #{color})"
    end

    puts "\n✨ Seeded #{user.wardrobe_items.count} items from local images"
  end

  desc "Clear all test wardrobe data"
  task clear_test_data: :environment do
    print "⚠️  This will delete all wardrobe items with 'test' or 'seed-data' tags. Continue? (y/n): "

    if STDIN.gets.chomp.downcase == 'y'
      count = WardrobeItem.where("tags @> ARRAY[?]::varchar[]", 'test')
                         .or(WardrobeItem.where("tags @> ARRAY[?]::varchar[]", 'seed-data'))
                         .destroy_all
                         .count

      puts "🗑️  Deleted #{count} test items"
    else
      puts "❌ Cancelled"
    end
  end
end
