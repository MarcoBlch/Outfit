# Railway Production Issue: User Signup Failing
## Date: January 8, 2026

## EXECUTIVE SUMMARY
User signup is failing with `ActiveRecord::NotNullViolation: ERROR: null value in column "id"` because the database DEFAULT clauses for id columns are missing. The migration to fix this exists but has not been executed on the production database.

---

## DETAILED DIAGNOSIS

### 1. Error Analysis
From Railway logs at 11:35:05 UTC on 2026-01-08:
```
ActiveRecord::NotNullViolation (PG::NotNullViolation: ERROR:  null value in column "id" of relation "users" violates not-null constraint
DETAIL:  Failing row contains (null, bernardmarc92@gmail.com, ...)
```

This confirms that PostgreSQL is not auto-generating the `id` value because the DEFAULT clause is missing.

### 2. Root Cause: Missing DEFAULT Clauses
PostgreSQL tables are missing `DEFAULT nextval('sequence_name')` on their `id` columns. This typically happens when:
- Database was restored from a dump that didn't preserve DEFAULT clauses
- Schema was loaded from `schema.rb` which doesn't always capture DEFAULTs correctly
- Migrations were not run after a database reset

### 3. Migration Status
**Migration file exists:** `/home/marc/code/MarcoBlch/Outfit/db/migrate/20260108120000_fix_all_id_sequence_defaults.rb`
**Schema version in repo:** `2025_12_05_232318` (December 5, 2025)
**Migration version:** `20260108120000` (January 8, 2026)

**CONCLUSION:** The migration file exists locally but either:
- Was not deployed to Railway, OR
- Did not execute during the database reset, OR
- Executed but failed silently

### 4. Why Database Reset Didn't Fix It
When `RESET_DATABASE=true` is set, the docker-entrypoint runs:
```bash
./bin/rails db:drop db:create db:migrate db:seed
```

However, `db:prepare` (used in normal deploys) often uses `db:schema:load` which loads from `schema.rb` instead of running migrations. Since `schema.rb` is at version `2025_12_05_232318`, the new migration is skipped.

### 5. Model Analysis
Checked User model and all other models for:
- `self.id =` assignments
- `before_create` callbacks that might set id to null
- `primary_key` overrides
- JWT/Devise conflicts

**RESULT:** No issues found. The User model is correctly configured with Devise and JWT.

---

## THE FIX

### Option 1: Execute SQL Directly (FASTEST - RECOMMENDED)
Run the fix script I created:

```bash
bash fix_railway_db.sh
```

This script will:
1. Check current schema version
2. Apply DEFAULT clauses to all id columns via SQL
3. Insert the migration record into schema_migrations
4. Verify the fix worked
5. Test user creation

### Option 2: Deploy and Force Migration
1. Commit the migration file if not already deployed:
   ```bash
   git add db/migrate/20260108120000_fix_all_id_sequence_defaults.rb
   git commit -m "Add migration to fix id DEFAULT clauses"
   git push
   ```

2. Force Railway to run pending migrations:
   ```bash
   railway run --service outfit-production -- rails db:migrate
   ```

3. Restart the service:
   ```bash
   railway up
   ```

### Option 3: Manual SQL via Railway Console
If the above don't work, execute this SQL directly:

```sql
-- Fix all id columns
ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);
ALTER TABLE wardrobe_items ALTER COLUMN id SET DEFAULT nextval('wardrobe_items_id_seq'::regclass);
ALTER TABLE outfits ALTER COLUMN id SET DEFAULT nextval('outfits_id_seq'::regclass);
ALTER TABLE outfit_items ALTER COLUMN id SET DEFAULT nextval('outfit_items_id_seq'::regclass);
ALTER TABLE outfit_suggestions ALTER COLUMN id SET DEFAULT nextval('outfit_suggestions_id_seq'::regclass);
ALTER TABLE user_profiles ALTER COLUMN id SET DEFAULT nextval('user_profiles_id_seq'::regclass);
ALTER TABLE subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);
ALTER TABLE ad_impressions ALTER COLUMN id SET DEFAULT nextval('ad_impressions_id_seq'::regclass);
ALTER TABLE product_recommendations ALTER COLUMN id SET DEFAULT nextval('product_recommendations_id_seq'::regclass);
ALTER TABLE active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('active_storage_attachments_id_seq'::regclass);
ALTER TABLE active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('active_storage_blobs_id_seq'::regclass);
ALTER TABLE active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('active_storage_variant_records_id_seq'::regclass);

-- Record the migration as run
INSERT INTO schema_migrations (version) VALUES ('20260108120000') ON CONFLICT DO NOTHING;
```

---

## VERIFICATION

After applying the fix, verify it worked:

1. **Check users table structure:**
   ```bash
   railway run -- rails runner "result = ActiveRecord::Base.connection.execute('SELECT column_name, column_default FROM information_schema.columns WHERE table_name = '\''users'\'' AND column_name = '\''id'\'''); puts result.values.first.inspect"
   ```

   Expected output: `["id", "nextval('users_id_seq'::regclass)"]`

2. **Test user creation:**
   Try signing up a new user through the web interface, or run:
   ```bash
   railway run -- rails runner "user = User.create!(email: 'test@example.com', password: 'TestPass123!', password_confirmation: 'TestPass123!'); puts \"User created with id: #{user.id}\"; user.destroy"
   ```

3. **Check Rails logs:**
   ```bash
   railway logs
   ```
   Should show successful user creation instead of NotNullViolation errors.

---

## PREVENTION

To prevent this issue in the future:

1. **Always update schema.rb after migrations:**
   ```bash
   rails db:migrate
   git add db/schema.rb db/migrate/
   git commit -m "Add migration and update schema"
   ```

2. **Use db:migrate in production, not db:schema:load:**
   Update docker-entrypoint to always run migrations:
   ```bash
   ./bin/rails db:migrate
   ```
   instead of:
   ```bash
   ./bin/rails db:prepare  # This may use schema:load
   ```

3. **Verify migrations ran on Railway:**
   After each deploy, check:
   ```bash
   railway run -- rails runner "puts ActiveRecord::Base.connection.select_values('SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 5').inspect"
   ```

4. **Use migration safety gems:**
   Consider adding `strong_migrations` gem to catch dangerous migrations before they run.

---

## FILES CREATED

1. `/home/marc/code/MarcoBlch/Outfit/db/fix_id_defaults.sql` - Direct SQL fix
2. `/home/marc/code/MarcoBlch/Outfit/fix_railway_db.sh` - Automated fix script
3. `/home/marc/code/MarcoBlch/Outfit/DIAGNOSIS_AND_FIX.md` - This document

---

## NEXT STEPS

1. Run `bash fix_railway_db.sh` to apply the fix immediately
2. Test user signup on Railway
3. Update schema.rb and commit it
4. Consider the prevention measures above

---

## TIMELINE OF INVESTIGATION

1. Analyzed Railway logs - Found NotNullViolation error with null id
2. Checked migration file - Correctly written, dated 2026-01-08
3. Checked schema.rb - Shows old version 2025-12-05
4. Analyzed User model - No issues found
5. Checked docker-entrypoint - Uses db:prepare which may skip migrations
6. Diagnosed root cause - Migration never executed on production database
7. Created fix scripts and verification procedures
