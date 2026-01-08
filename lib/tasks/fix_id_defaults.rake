namespace :db do
  desc "Fix missing DEFAULT nextval() on id columns"
  task fix_id_defaults: :environment do
    puts "=========================================="
    puts "Fixing ID DEFAULT clauses"
    puts "=========================================="

    tables = %w[
      active_storage_attachments
      active_storage_blobs
      active_storage_variant_records
      ad_impressions
      outfit_items
      outfit_suggestions
      outfits
      product_recommendations
      subscriptions
      user_profiles
      users
      wardrobe_items
    ]

    # Check current state first
    puts "\n1. Checking users table BEFORE fix..."
    result = ActiveRecord::Base.connection.execute(
      "SELECT column_name, column_default FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'id'"
    )
    puts "   Current: #{result.values.first.inspect}"

    # Apply fixes
    puts "\n2. Applying fixes..."
    tables.each do |table_name|
      sequence_name = "#{table_name}_id_seq"
      begin
        ActiveRecord::Base.connection.execute(
          "ALTER TABLE #{table_name} ALTER COLUMN id SET DEFAULT nextval('#{sequence_name}'::regclass)"
        )
        puts "   ✓ Fixed #{table_name}"
      rescue => e
        puts "   ✗ Error fixing #{table_name}: #{e.message}"
      end
    end

    # Insert migration record
    puts "\n3. Recording migration as complete..."
    ActiveRecord::Base.connection.execute(
      "INSERT INTO schema_migrations (version) VALUES ('20260108120000') ON CONFLICT DO NOTHING"
    )
    puts "   ✓ Migration recorded"

    # Verify fix
    puts "\n4. Checking users table AFTER fix..."
    result = ActiveRecord::Base.connection.execute(
      "SELECT column_name, column_default FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'id'"
    )
    puts "   Current: #{result.values.first.inspect}"

    # Test user creation
    puts "\n5. Testing user creation..."
    begin
      test_email = "test_#{Time.now.to_i}@example.com"
      user = User.create!(
        email: test_email,
        password: "TestPassword123!",
        password_confirmation: "TestPassword123!"
      )
      puts "   ✓ SUCCESS! User created with id: #{user.id}"
      user.destroy
      puts "   ✓ Test user cleaned up"
    rescue => e
      puts "   ✗ FAILED: #{e.message}"
    end

    puts "\n=========================================="
    puts "Fix completed!"
    puts "=========================================="
  end
end
