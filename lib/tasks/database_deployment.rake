# frozen_string_literal: true

namespace :db do
  # ==============================================================================
  # Production Database Initialization Tasks
  # ==============================================================================
  # These tasks are called by the docker-entrypoint script to ensure safe
  # database initialization and updates for Railway deployments.
  # ==============================================================================

  desc "Initialize production database on first deploy"
  task initialize_production: :environment do
    puts "=" * 80
    puts "Running post-initialization tasks..."
    puts "=" * 80

    # Ensure ID sequence defaults are set
    Rake::Task["db:ensure_id_defaults"].invoke

    # Run any custom initialization logic here
    # For example, create default admin user, seed essential data, etc.

    puts "\n[SUCCESS] Production database initialization complete"
    puts "=" * 80
  end

  desc "Run post-migration tasks on existing database"
  task post_migrate: :environment do
    puts "=" * 80
    puts "Running post-migration tasks..."
    puts "=" * 80

    # Ensure ID sequence defaults are set (idempotent)
    Rake::Task["db:ensure_id_defaults"].invoke

    # Verify database integrity
    Rake::Task["db:verify_integrity"].invoke

    puts "\n[SUCCESS] Post-migration tasks complete"
    puts "=" * 80
  end

  desc "Ensure all ID columns have DEFAULT nextval() clauses"
  task ensure_id_defaults: :environment do
    puts "\n--- Ensuring ID Defaults ---"

    # List of all tables that should have sequence-based IDs
    tables_with_sequences = %w[
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

    # Check and fix each table
    tables_with_sequences.each do |table_name|
      sequence_name = "#{table_name}_id_seq"

      # Check if table exists
      unless ActiveRecord::Base.connection.table_exists?(table_name)
        puts "  [SKIP] Table #{table_name} does not exist"
        next
      end

      # Get current default for id column
      result = ActiveRecord::Base.connection.execute(
        "SELECT column_default FROM information_schema.columns WHERE table_name = '#{table_name}' AND column_name = 'id'"
      ).first

      if result.nil?
        puts "  [SKIP] Table #{table_name} has no id column"
        next
      end

      current_default = result["column_default"]

      # Check if default is already set correctly
      if current_default&.include?("nextval")
        puts "  [OK] #{table_name} already has correct DEFAULT"
      else
        # Fix the default
        begin
          ActiveRecord::Base.connection.execute(
            "ALTER TABLE #{table_name} ALTER COLUMN id SET DEFAULT nextval('#{sequence_name}'::regclass)"
          )
          puts "  [FIXED] #{table_name} DEFAULT set to nextval('#{sequence_name}')"
        rescue StandardError => e
          puts "  [ERROR] Failed to fix #{table_name}: #{e.message}"
        end
      end
    end

    puts "[COMPLETE] ID defaults check finished\n"
  end

  desc "Verify database integrity"
  task verify_integrity: :environment do
    puts "\n--- Verifying Database Integrity ---"

    errors = []

    # Check that essential tables exist
    essential_tables = %w[users wardrobe_items outfits schema_migrations]
    essential_tables.each do |table_name|
      unless ActiveRecord::Base.connection.table_exists?(table_name)
        errors << "Missing essential table: #{table_name}"
      end
    end

    # Check that sequences are owned by the correct columns
    tables_to_check = %w[users wardrobe_items outfits]
    tables_to_check.each do |table_name|
      next unless ActiveRecord::Base.connection.table_exists?(table_name)

      sequence_name = "#{table_name}_id_seq"

      begin
        result = ActiveRecord::Base.connection.execute(
          "SELECT pg_get_serial_sequence('#{table_name}', 'id') AS sequence_name"
        ).first

        if result["sequence_name"] != sequence_name
          errors << "Sequence mismatch for #{table_name}: expected #{sequence_name}, got #{result['sequence_name']}"
        else
          puts "  [OK] #{table_name} sequence is correctly configured"
        end
      rescue StandardError => e
        errors << "Error checking sequence for #{table_name}: #{e.message}"
      end
    end

    # Check that we can create a test record (if no users exist)
    if User.count.zero?
      begin
        test_email = "integrity_test_#{Time.now.to_i}@example.com"
        user = User.create!(
          email: test_email,
          password: "TestPassword123!",
          password_confirmation: "TestPassword123!"
        )
        puts "  [OK] Successfully created test user with ID: #{user.id}"
        user.destroy
        puts "  [OK] Successfully cleaned up test user"
      rescue StandardError => e
        errors << "Failed to create test user: #{e.message}"
      end
    else
      puts "  [SKIP] Users exist, skipping test user creation"
    end

    if errors.any?
      puts "\n[WARNING] Database integrity issues found:"
      errors.each { |error| puts "  - #{error}" }
      puts "\nThese issues may need manual intervention."
    else
      puts "[SUCCESS] Database integrity verified\n"
    end
  end

  desc "Emergency database repair (use with caution)"
  task repair: :environment do
    puts "=" * 80
    puts "EMERGENCY DATABASE REPAIR"
    puts "=" * 80
    puts "\nThis task will attempt to repair common database issues."
    puts "Use with caution in production!"
    puts ""

    # 1. Ensure schema_migrations exists
    unless ActiveRecord::Base.connection.table_exists?("schema_migrations")
      puts "[REPAIR] Creating schema_migrations table..."
      ActiveRecord::Base.connection.create_table :schema_migrations, id: false do |t|
        t.string :version, null: false
      end
      ActiveRecord::Base.connection.add_index :schema_migrations, :version, unique: true
      puts "[SUCCESS] schema_migrations table created"
    else
      puts "[OK] schema_migrations table exists"
    end

    # 2. Ensure ar_internal_metadata exists
    unless ActiveRecord::Base.connection.table_exists?("ar_internal_metadata")
      puts "[REPAIR] Creating ar_internal_metadata table..."
      ActiveRecord::Base.connection.create_table :ar_internal_metadata, id: false do |t|
        t.string :key, null: false
        t.string :value
        t.timestamps
      end
      ActiveRecord::Base.connection.add_index :ar_internal_metadata, :key, unique: true
      puts "[SUCCESS] ar_internal_metadata table created"
    else
      puts "[OK] ar_internal_metadata table exists"
    end

    # 3. Fix ID defaults
    puts "\n[REPAIR] Fixing ID defaults..."
    Rake::Task["db:ensure_id_defaults"].invoke

    # 4. Verify integrity
    puts "\n[REPAIR] Verifying database integrity..."
    Rake::Task["db:verify_integrity"].invoke

    puts "\n" + "=" * 80
    puts "REPAIR COMPLETE"
    puts "=" * 80
    puts "\nNext steps:"
    puts "1. Check the output above for any remaining errors"
    puts "2. Run 'rails db:migrate' to apply any pending migrations"
    puts "3. Test the application thoroughly"
    puts "=" * 80
  end

  desc "Display database status for Railway deployments"
  task deployment_status: :environment do
    puts "=" * 80
    puts "RAILWAY DEPLOYMENT DATABASE STATUS"
    puts "=" * 80

    # Database connection
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "\n[✓] Database connection: OK"
      puts "    Database: #{ActiveRecord::Base.connection.current_database}"
    rescue StandardError => e
      puts "\n[✗] Database connection: FAILED"
      puts "    Error: #{e.message}"
      exit 1
    end

    # Schema version
    begin
      version = ActiveRecord::Base.connection.select_value(
        "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
      )
      puts "\n[✓] Schema version: #{version}"
    rescue StandardError => e
      puts "\n[✗] Schema version: FAILED"
      puts "    Error: #{e.message}"
    end

    # Pending migrations
    begin
      migrations = ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths).pending_migrations
      if migrations.empty?
        puts "\n[✓] Pending migrations: None"
      else
        puts "\n[!] Pending migrations: #{migrations.count}"
        migrations.each do |migration|
          puts "    - #{migration.version} #{migration.name}"
        end
      end
    rescue StandardError => e
      puts "\n[✗] Migration check: FAILED"
      puts "    Error: #{e.message}"
    end

    # Table count
    begin
      tables = ActiveRecord::Base.connection.tables - ["schema_migrations", "ar_internal_metadata"]
      puts "\n[✓] Application tables: #{tables.count}"
    rescue StandardError => e
      puts "\n[✗] Table count: FAILED"
      puts "    Error: #{e.message}"
    end

    # Record counts
    begin
      puts "\n[✓] Record counts:"
      puts "    Users: #{User.count}"
      puts "    Wardrobe Items: #{WardrobeItem.count}"
      puts "    Outfits: #{Outfit.count}"
    rescue StandardError => e
      puts "\n[✗] Record counts: FAILED"
      puts "    Error: #{e.message}"
    end

    # ID defaults check
    begin
      result = ActiveRecord::Base.connection.execute(
        "SELECT column_default FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'id'"
      ).first

      if result && result["column_default"]&.include?("nextval")
        puts "\n[✓] ID defaults: Configured correctly"
      else
        puts "\n[!] ID defaults: Missing or incorrect"
        puts "    Run: rails db:ensure_id_defaults"
      end
    rescue StandardError => e
      puts "\n[✗] ID defaults check: FAILED"
      puts "    Error: #{e.message}"
    end

    puts "\n" + "=" * 80
    puts "STATUS CHECK COMPLETE"
    puts "=" * 80
  end
end
