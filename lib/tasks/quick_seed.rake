namespace :wardrobe do
  desc "Quick seed with 50+ items for testing (uses placeholder images, no downloads)"
  task quick_seed: :environment do
    puts "🚀 Quick seeding 50+ wardrobe items..."

    user = User.find_or_create_by!(email: 'test@example.com') do |u|
      u.password = 'password123'
      u.password_confirmation = 'password123'
    end

    # Create user profile if missing
    unless user.user_profile
      user.create_user_profile!(
        style_preference: 'casual',
        age_range: '25-34',
        location: 'New York'
      )
    end

    puts "👤 User: #{user.email}"
    puts "📦 Creating wardrobe items..."

    # Diverse wardrobe items - 50+ items across all categories
    items = [
      # Tops (15 items)
      { category: 'top', color: 'white' }, { category: 'top', color: 'black' },
      { category: 'top', color: 'gray' }, { category: 'top', color: 'navy' },
      { category: 'shirt', color: 'blue' }, { category: 'shirt', color: 'white' },
      { category: 'shirt', color: 'pink' }, { category: 'blouse', color: 'cream' },
      { category: 'blouse', color: 'floral' }, { category: 'sweater', color: 'beige' },
      { category: 'sweater', color: 'burgundy' }, { category: 'cardigan', color: 'gray' },
      { category: 'tank top', color: 'white' }, { category: 'polo', color: 'navy' },
      { category: 'turtleneck', color: 'black' },

      # Bottoms (12 items)
      { category: 'jeans', color: 'blue' }, { category: 'jeans', color: 'black' },
      { category: 'pants', color: 'khaki' }, { category: 'pants', color: 'black' },
      { category: 'trousers', color: 'gray' }, { category: 'chinos', color: 'beige' },
      { category: 'skirt', color: 'black' }, { category: 'skirt', color: 'plaid' },
      { category: 'shorts', color: 'denim' }, { category: 'shorts', color: 'khaki' },
      { category: 'leggings', color: 'black' }, { category: 'joggers', color: 'gray' },

      # Dresses (6 items)
      { category: 'dress', color: 'black' }, { category: 'dress', color: 'floral' },
      { category: 'dress', color: 'red' }, { category: 'maxi dress', color: 'navy' },
      { category: 'sundress', color: 'white' }, { category: 'cocktail dress', color: 'emerald' },

      # Outerwear (8 items)
      { category: 'jacket', color: 'denim' }, { category: 'jacket', color: 'leather' },
      { category: 'blazer', color: 'navy' }, { category: 'blazer', color: 'black' },
      { category: 'coat', color: 'camel' }, { category: 'coat', color: 'black' },
      { category: 'hoodie', color: 'gray' }, { category: 'bomber jacket', color: 'olive' },

      # Shoes (10 items)
      { category: 'sneakers', color: 'white' }, { category: 'sneakers', color: 'black' },
      { category: 'heels', color: 'black' }, { category: 'heels', color: 'nude' },
      { category: 'boots', color: 'brown' }, { category: 'boots', color: 'black' },
      { category: 'sandals', color: 'tan' }, { category: 'loafers', color: 'burgundy' },
      { category: 'running shoes', color: 'blue' }, { category: 'flats', color: 'black' },

      # Accessories (8 items)
      { category: 'bag', color: 'brown' }, { category: 'bag', color: 'black' },
      { category: 'hat', color: 'beige' }, { category: 'scarf', color: 'multicolor' },
      { category: 'belt', color: 'brown' }, { category: 'belt', color: 'black' },
      { category: 'sunglasses', color: 'black' }, { category: 'watch', color: 'silver' },
    ]

    # Create simple colored placeholder images
    COLOR_MAP = {
      'white' => '#FFFFFF', 'black' => '#000000', 'gray' => '#808080',
      'navy' => '#000080', 'blue' => '#0000FF', 'pink' => '#FFC0CB',
      'cream' => '#FFFDD0', 'floral' => '#FF69B4', 'beige' => '#F5F5DC',
      'burgundy' => '#800020', 'khaki' => '#C3B091', 'plaid' => '#8B4513',
      'denim' => '#1560BD', 'red' => '#FF0000', 'emerald' => '#50C878',
      'leather' => '#3B2F2F', 'camel' => '#C19A6B', 'olive' => '#808000',
      'brown' => '#A52A2A', 'nude' => '#E3BC9A', 'tan' => '#D2B48C',
      'multicolor' => '#FF00FF', 'silver' => '#C0C0C0'
    }

    temp_dir = Rails.root.join('tmp', 'quick_seed')
    FileUtils.mkdir_p(temp_dir)

    items.each_with_index do |item_data, index|
      hex_color = COLOR_MAP[item_data[:color]] || '#CCCCCC'

      # Create a simple colored square image using ImageMagick directly
      temp_file = temp_dir.join("item_#{index}.png")
      system("convert -size 400x400 xc:'#{hex_color}' #{temp_file}")

      item = user.wardrobe_items.new(
        category: item_data[:category],
        color: item_data[:color]
      )

      item.image.attach(
        io: File.open(temp_file),
        filename: "#{item_data[:category]}_#{item_data[:color]}.png",
        content_type: 'image/png'
      )

      item.save!

      print "."
    end

    FileUtils.rm_rf(temp_dir)

    puts "\n✨ Created #{items.count} items!"
    puts "Total in wardrobe: #{user.wardrobe_items.count}"
    puts "Ready for testing outfit suggestions!"
  end
end
