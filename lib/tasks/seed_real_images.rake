namespace :wardrobe do
  desc "Seed wardrobe with real fashion images from Unsplash (free, high-quality)"
  task seed_real_images: :environment do
    require 'open-uri'
    require 'fileutils'

    puts "🚀 Seeding wardrobe with real fashion images..."
    puts "📸 Downloading from Unsplash (free high-quality stock photos)"

    user = User.find_or_create_by!(email: 'test@example.com') do |u|
      u.password = 'password123'
      u.password_confirmation = 'password123'
    end

    # Create user profile if missing
    unless user.user_profile
      user.create_user_profile!(
        style_preference: 'business_casual',
        body_type: 'athletic',
        presentation_style: 'feminine',
        age_range: '25-34',
        location: 'New York, NY'
      )
      user.user_profile.favorite_colors = ['Navy', 'White', 'Gray', 'Black']
      user.user_profile.save!
    end

    puts "👤 User: #{user.email}"
    puts "📦 Downloading real fashion images..."

    # Real fashion items from Unsplash
    # Format: { category, color, unsplash_id }
    items = [
      # TOPS (15 items)
      { category: 'white blouse', color: 'white', url: 'https://images.unsplash.com/photo-1618932260643-eee4a2f652a6?w=800&h=800&fit=crop' },
      { category: 'black t-shirt', color: 'black', url: 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&h=800&fit=crop' },
      { category: 'gray sweater', color: 'gray', url: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=800&fit=crop' },
      { category: 'navy blazer', color: 'navy', url: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop' },
      { category: 'blue shirt', color: 'blue', url: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&h=800&fit=crop' },
      { category: 'white tank top', color: 'white', url: 'https://images.unsplash.com/photo-1627225925683-1da7021732ea?w=800&h=800&fit=crop' },
      { category: 'striped shirt', color: 'white', url: 'https://images.unsplash.com/photo-1598032895725-b6c7e2f8c2fb?w=800&h=800&fit=crop' },
      { category: 'pink blouse', color: 'pink', url: 'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?w=800&h=800&fit=crop' },
      { category: 'burgundy sweater', color: 'burgundy', url: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&h=800&fit=crop' },
      { category: 'gray cardigan', color: 'gray', url: 'https://images.unsplash.com/photo-1591369822096-ffd140ec948f?w=800&h=800&fit=crop' },
      { category: 'black turtleneck', color: 'black', url: 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=800&fit=crop' },
      { category: 'cream sweater', color: 'cream', url: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&h=800&fit=crop' },
      { category: 'white button-up', color: 'white', url: 'https://images.unsplash.com/photo-1607345366928-199ea26cfe3e?w=800&h=800&fit=crop' },
      { category: 'navy polo', color: 'navy', url: 'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?w=800&h=800&fit=crop' },
      { category: 'beige sweater', color: 'beige', url: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=800&fit=crop' },

      # BOTTOMS (12 items)
      { category: 'blue jeans', color: 'blue', url: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=800&fit=crop' },
      { category: 'black jeans', color: 'black', url: 'https://images.unsplash.com/photo-1604176354204-9268737828e4?w=800&h=800&fit=crop' },
      { category: 'khaki pants', color: 'khaki', url: 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&h=800&fit=crop' },
      { category: 'black trousers', color: 'black', url: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=800&h=800&fit=crop' },
      { category: 'gray trousers', color: 'gray', url: 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=800&h=800&fit=crop' },
      { category: 'beige chinos', color: 'beige', url: 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800&h=800&fit=crop' },
      { category: 'black skirt', color: 'black', url: 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&h=800&fit=crop' },
      { category: 'plaid skirt', color: 'gray', url: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=800&h=800&fit=crop' },
      { category: 'denim shorts', color: 'blue', url: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop' },
      { category: 'black leggings', color: 'black', url: 'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800&h=800&fit=crop' },
      { category: 'gray joggers', color: 'gray', url: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop' },
      { category: 'khaki shorts', color: 'khaki', url: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop' },

      # DRESSES (6 items)
      { category: 'black dress', color: 'black', url: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&h=800&fit=crop' },
      { category: 'floral dress', color: 'multicolor', url: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop' },
      { category: 'red dress', color: 'red', url: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&h=800&fit=crop' },
      { category: 'navy maxi dress', color: 'navy', url: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop' },
      { category: 'white sundress', color: 'white', url: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop' },
      { category: 'emerald cocktail dress', color: 'green', url: 'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=800&h=800&fit=crop' },

      # OUTERWEAR (8 items)
      { category: 'denim jacket', color: 'blue', url: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=800&fit=crop' },
      { category: 'leather jacket', color: 'black', url: 'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?w=800&h=800&fit=crop' },
      { category: 'navy blazer', color: 'navy', url: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&h=800&fit=crop' },
      { category: 'black blazer', color: 'black', url: 'https://images.unsplash.com/photo-1592878849190-c0e0a5d0abf4?w=800&h=800&fit=crop' },
      { category: 'camel coat', color: 'brown', url: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop' },
      { category: 'black coat', color: 'black', url: 'https://images.unsplash.com/photo-1544923408-75c5cef46f14?w=800&h=800&fit=crop' },
      { category: 'gray hoodie', color: 'gray', url: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop' },
      { category: 'olive bomber jacket', color: 'green', url: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=800&fit=crop' },

      # SHOES (10 items)
      { category: 'white sneakers', color: 'white', url: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=800&fit=crop' },
      { category: 'black sneakers', color: 'black', url: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=800&fit=crop' },
      { category: 'black heels', color: 'black', url: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop' },
      { category: 'nude heels', color: 'beige', url: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=800&h=800&fit=crop' },
      { category: 'brown boots', color: 'brown', url: 'https://images.unsplash.com/photo-1520639888713-7851133b1ed0?w=800&h=800&fit=crop' },
      { category: 'black boots', color: 'black', url: 'https://images.unsplash.com/photo-1542834759-b98e15c92b15?w=800&h=800&fit=crop' },
      { category: 'tan sandals', color: 'brown', url: 'https://images.unsplash.com/photo-1603487742131-4160ec999306?w=800&h=800&fit=crop' },
      { category: 'burgundy loafers', color: 'burgundy', url: 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&h=800&fit=crop' },
      { category: 'blue running shoes', color: 'blue', url: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800&h=800&fit=crop' },
      { category: 'black flats', color: 'black', url: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop' },

      # ACCESSORIES (8 items)
      { category: 'brown leather bag', color: 'brown', url: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&h=800&fit=crop' },
      { category: 'black handbag', color: 'black', url: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?w=800&h=800&fit=crop' },
      { category: 'beige hat', color: 'beige', url: 'https://images.unsplash.com/photo-1529958030586-3aae4ca485ff?w=800&h=800&fit=crop' },
      { category: 'multicolor scarf', color: 'multicolor', url: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=800&h=800&fit=crop' },
      { category: 'brown leather belt', color: 'brown', url: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&h=800&fit=crop' },
      { category: 'black belt', color: 'black', url: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800&h=800&fit=crop' },
      { category: 'black sunglasses', color: 'black', url: 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=800&h=800&fit=crop' },
      { category: 'silver watch', color: 'silver', url: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=800&h=800&fit=crop' },
    ]

    temp_dir = Rails.root.join('tmp', 'seed_images')
    FileUtils.mkdir_p(temp_dir)

    success_count = 0
    failed_count = 0

    items.each_with_index do |item_data, index|
      begin
        print "#{index + 1}/#{items.count} "

        # Download image
        temp_file = temp_dir.join("item_#{index}.jpg")
        URI.open(item_data[:url]) do |image|
          File.open(temp_file, 'wb') do |file|
            file.write(image.read)
          end
        end

        # Create wardrobe item
        item = user.wardrobe_items.new(
          category: item_data[:category],
          color: item_data[:color]
        )

        item.image.attach(
          io: File.open(temp_file),
          filename: "#{item_data[:category].gsub(' ', '_')}.jpg",
          content_type: 'image/jpeg'
        )

        item.save!
        success_count += 1
        print "✓ #{item_data[:category]}\n"

      rescue => e
        failed_count += 1
        puts "✗ Failed: #{item_data[:category]} - #{e.message}"
      end

      # Be nice to Unsplash servers
      sleep 0.5
    end

    FileUtils.rm_rf(temp_dir)

    puts "\n" + "="*60
    puts "✨ Seeding complete!"
    puts "="*60
    puts "✓ Successfully created: #{success_count} items"
    puts "✗ Failed: #{failed_count} items" if failed_count > 0
    puts "📊 Total in wardrobe: #{user.wardrobe_items.count}"
    puts "\n🎨 Ready to test AI outfit suggestions!"
    puts "💡 Try contexts like:"
    puts "   - 'job interview at a tech startup'"
    puts "   - 'casual Friday at the office'"
    puts "   - 'date night at a nice restaurant'"
    puts "   - 'weekend brunch with friends'"
  end
end
