-- Direct SQL fix for missing DEFAULT clauses on id columns
-- This matches the fix_all_id_sequence_defaults migration
-- Run this directly on Railway database

BEGIN;

-- Fix all tables that have bigint id columns with sequences
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

-- Insert the migration record so Rails knows it ran
INSERT INTO schema_migrations (version) VALUES ('20260108120000') ON CONFLICT DO NOTHING;

-- Verify the fix for the users table
SELECT
    column_name,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'id';

COMMIT;
