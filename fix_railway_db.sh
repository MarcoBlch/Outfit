#!/bin/bash

echo "=========================================="
echo "Railway Database Fix Script"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Check current schema version"
echo "2. Apply the id DEFAULT fixes"
echo "3. Verify the fix worked"
echo ""

# Step 1: Check current state
echo "Step 1: Checking current schema version..."
railway run -- rails runner "puts 'Current schema version: ' + ActiveRecord::Base.connection.select_value('SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1').to_s"

echo ""
echo "Step 2: Checking users table structure BEFORE fix..."
railway run -- rails runner "result = ActiveRecord::Base.connection.execute('SELECT column_name, column_default FROM information_schema.columns WHERE table_name = '\''users'\'' AND column_name = '\''id'\'''); puts result.values.first.inspect"

echo ""
echo "Step 3: Applying the fix via direct SQL..."
railway run -- rails runner "
ActiveRecord::Base.connection.execute <<-SQL
  ALTER TABLE active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('active_storage_attachments_id_seq'::regclass);
  ALTER TABLE active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('active_storage_blobs_id_seq'::regclass);
  ALTER TABLE active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('active_storage_variant_records_id_seq'::regclass);
  ALTER TABLE ad_impressions ALTER COLUMN id SET DEFAULT nextval('ad_impressions_id_seq'::regclass);
  ALTER TABLE outfit_items ALTER COLUMN id SET DEFAULT nextval('outfit_items_id_seq'::regclass);
  ALTER TABLE outfit_suggestions ALTER COLUMN id SET DEFAULT nextval('outfit_suggestions_id_seq'::regclass);
  ALTER TABLE outfits ALTER COLUMN id SET DEFAULT nextval('outfits_id_seq'::regclass);
  ALTER TABLE product_recommendations ALTER COLUMN id SET DEFAULT nextval('product_recommendations_id_seq'::regclass);
  ALTER TABLE subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);
  ALTER TABLE user_profiles ALTER COLUMN id SET DEFAULT nextval('user_profiles_id_seq'::regclass);
  ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);
  ALTER TABLE wardrobe_items ALTER COLUMN id SET DEFAULT nextval('wardrobe_items_id_seq'::regclass);
  INSERT INTO schema_migrations (version) VALUES ('20260108120000') ON CONFLICT DO NOTHING;
SQL
puts 'Fix applied successfully!'
"

echo ""
echo "Step 4: Verifying users table structure AFTER fix..."
railway run -- rails runner "result = ActiveRecord::Base.connection.execute('SELECT column_name, column_default FROM information_schema.columns WHERE table_name = '\''users'\'' AND column_name = '\''id'\'''); puts result.values.first.inspect"

echo ""
echo "Step 5: Testing user creation..."
railway run -- rails runner "
begin
  test_email = 'test_' + Time.now.to_i.to_s + '@example.com'
  user = User.create!(email: test_email, password: 'TestPassword123!', password_confirmation: 'TestPassword123!')
  puts \"SUCCESS! User created with id: #{user.id}\"
  user.destroy
  puts 'Test user cleaned up.'
rescue => e
  puts \"FAILED: #{e.message}\"
end
"

echo ""
echo "=========================================="
echo "Fix script completed!"
echo "=========================================="
