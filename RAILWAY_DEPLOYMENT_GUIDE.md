# Railway Deployment Guide - Production-Ready Solution

**Last Updated**: 2026-01-08
**Status**: Production Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Deployment Workflow](#deployment-workflow)
4. [Health Checks](#health-checks)
5. [Troubleshooting](#troubleshooting)
6. [Emergency Procedures](#emergency-procedures)
7. [Maintenance Tasks](#maintenance-tasks)

---

## Overview

This guide documents the bulletproof deployment solution for Railway. The solution handles:

- First-time deploys to an empty database
- Subsequent deploys to existing databases with data
- Database schema mismatches and repair scenarios
- Migration failures and recovery
- Zero-downtime deployments

### Key Features

- **Idempotent**: Can run multiple times safely without side effects
- **Self-Healing**: Automatically detects and repairs common database issues
- **Preserves Data**: Never drops or loses user data
- **Clear Logging**: Color-coded logs for easy debugging in Railway dashboard
- **Health Checks**: Multiple endpoints for monitoring app health

---

## Architecture

### Components

1. **docker-entrypoint** (`/bin/docker-entrypoint`)
   - Main entrypoint script executed when container starts
   - Performs intelligent database initialization based on current state
   - Handles three scenarios: new database, existing database, corrupted database

2. **Database Deployment Tasks** (`/lib/tasks/database_deployment.rake`)
   - `db:initialize_production` - Run after first schema load
   - `db:post_migrate` - Run after migrations on existing database
   - `db:ensure_id_defaults` - Fix ID sequence defaults (idempotent)
   - `db:verify_integrity` - Check database health
   - `db:repair` - Emergency repair for corrupted databases
   - `db:deployment_status` - Show current database status

3. **Health Check Controller** (`/app/controllers/health_controller.rb`)
   - Multiple endpoints for different monitoring needs
   - Database connectivity verification
   - Readiness and liveness probes

### Decision Tree

The entrypoint script follows this decision logic:

```
Start
  |
  v
Is database accessible?
  |-- NO --> Wait up to 60 seconds --> Still NO? --> EXIT with error
  |
  v YES
  |
Does schema_migrations table exist?
  |-- NO --> Initialize New Database
  |           |-- db:create
  |           |-- db:schema:load
  |           |-- db:migrate (for migrations newer than schema.rb)
  |           |-- db:initialize_production
  |           |-- Done
  |
  v YES
  |
Do application tables exist?
  |-- NO --> Repair Database (partial migration failure)
  |           |-- db:schema:load
  |           |-- db:migrate
  |           |-- Done
  |
  v YES
  |
Are there pending migrations?
  |-- YES --> Update Existing Database
  |           |-- db:migrate
  |           |-- db:post_migrate
  |           |-- Done
  |
  v NO
  |
Database is up to date
  |-- db:post_migrate (run anyway for fixes)
  |-- Done
```

---

## Deployment Workflow

### First-Time Deployment

When deploying to a completely new Railway environment:

1. **Setup Railway Service**
   ```bash
   # Create new service (if not already done)
   railway link

   # Add PostgreSQL database
   railway add postgresql
   ```

2. **Configure Environment Variables**
   ```bash
   # Required variables
   railway variables --set "RAILS_ENV=production"
   railway variables --set "RAILS_MASTER_KEY=<your_master_key>"

   # DATABASE_URL is automatically set by Railway's PostgreSQL plugin
   ```

3. **Deploy Application**
   ```bash
   git add .
   git commit -m "Initial deployment setup"
   git push

   # Railway automatically deploys on push
   # Or manually trigger:
   railway up --detach
   ```

4. **Monitor Deployment**
   ```bash
   # Watch logs in real-time
   railway logs
   ```

5. **Verify Health**
   ```bash
   # Check if app is ready
   curl https://your-app.railway.app/health/ready

   # Get detailed status
   curl https://your-app.railway.app/health/detailed
   ```

### Expected First-Time Log Output

```
========================================
Docker Entrypoint Started
========================================
[INFO] Rails environment: production
[INFO] Ruby version: ruby 3.3.5
[INFO] Rails version: Rails 7.1.6

========================================
Database Initialization Starting
========================================
[INFO] Waiting for database to be ready...
[INFO] Checking if database exists and is accessible...
[SUCCESS] Database is accessible
[INFO] Checking if schema_migrations table exists...
[WARNING] schema_migrations table does not exist

========================================
Initializing New Database
========================================
[INFO] Creating database...
[WARNING] Database may already exist
[INFO] Loading schema from schema.rb...
[INFO] Running any additional migrations not in schema.rb...
[INFO] Running post-initialization tasks...

--- Ensuring ID Defaults ---
  [FIXED] users DEFAULT set to nextval('users_id_seq')
  [FIXED] wardrobe_items DEFAULT set to nextval('wardrobe_items_id_seq')
  ...
[COMPLETE] ID defaults check finished

[SUCCESS] New database initialized successfully

========================================
Database Initialization Complete
========================================

========================================
Application Starting
========================================
[INFO] Starting Rails server...
[INFO] Server will be available shortly
```

### Subsequent Deployments

When deploying updates to an existing database:

1. **Make Changes**
   - Add new migrations
   - Update application code
   - Update dependencies

2. **Commit and Push**
   ```bash
   git add .
   git commit -m "Add new feature with migration"
   git push
   ```

3. **Railway Auto-Deploys**
   - Pulls latest code
   - Builds Docker image
   - Runs docker-entrypoint
   - Entrypoint detects pending migrations
   - Runs `db:migrate` and `db:post_migrate`
   - Starts Rails server

### Expected Update Log Output

```
========================================
Database Initialization Starting
========================================
[INFO] Checking if schema_migrations table exists...
[SUCCESS] schema_migrations table exists
[INFO] Checking if application tables exist...
[SUCCESS] Found 12 application tables
[SUCCESS] Database is already initialized
[INFO] Checking for pending migrations...
[WARNING] Pending migrations found

========================================
Updating Existing Database
========================================
[INFO] Running pending migrations...
== 20260109120000 AddNewFeature: migrating ===================================
-- add_column(:users, :new_field, :string)
   -> 0.0234s
== 20260109120000 AddNewFeature: migrated (0.0235s) ==========================

[INFO] Running post-migration tasks...

--- Ensuring ID Defaults ---
  [OK] users already has correct DEFAULT
  [OK] wardrobe_items already has correct DEFAULT
  ...
[COMPLETE] ID defaults check finished

[SUCCESS] Database updated successfully
```

---

## Health Checks

### Available Endpoints

#### 1. `/up` (Default Rails Health Check)
- **Purpose**: Basic uptime monitoring
- **Returns**: 200 if app boots without exceptions
- **Use for**: Railway's built-in health checks

```bash
curl https://your-app.railway.app/up
# Response: OK
```

#### 2. `/health` (Simple Check)
- **Purpose**: Quick health check with timestamp
- **Returns**: JSON with status and timestamp
- **Use for**: Simple monitoring scripts

```bash
curl https://your-app.railway.app/health
# Response: {"status":"ok","timestamp":"2026-01-08T12:00:00Z"}
```

#### 3. `/health/detailed` (Detailed Check)
- **Purpose**: Comprehensive health check
- **Checks**: Database connectivity, schema version, data access
- **Use for**: Debugging and detailed monitoring

```bash
curl https://your-app.railway.app/health/detailed
# Response:
# {
#   "status": "ok",
#   "checks": {
#     "timestamp": "2026-01-08T12:00:00Z",
#     "environment": "production",
#     "rails_version": "7.1.6",
#     "ruby_version": "3.3.5",
#     "database": "ok",
#     "schema_version": "2026_01_08_120000",
#     "user_count": 42,
#     "data_access": "ok"
#   }
# }
```

#### 4. `/health/ready` (Readiness Probe)
- **Purpose**: Check if app is ready to serve traffic
- **Checks**: Database accessible, essential tables exist
- **Use for**: Load balancer readiness checks

```bash
curl https://your-app.railway.app/health/ready
# Response:
# {
#   "ready": true,
#   "checks": {
#     "database": true,
#     "tables": true
#   }
# }
```

#### 5. `/health/live` (Liveness Probe)
- **Purpose**: Check if app is alive and responsive
- **Use for**: Container orchestration liveness checks

```bash
curl https://your-app.railway.app/health/live
# Response: {"alive":true,"timestamp":"2026-01-08T12:00:00Z"}
```

### Configuring Railway Health Checks

In Railway dashboard or `railway.toml`:

```toml
[deploy]
healthcheckPath = "/health/ready"
healthcheckTimeout = 300  # 5 minutes for initial startup
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 10
```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Migrations Not Running

**Symptoms:**
- App deploys successfully but migrations don't run
- Old schema version reported in `/health/detailed`

**Diagnosis:**
```bash
railway run rails db:deployment_status
```

**Solution:**
```bash
# Manually run migrations
railway run rails db:migrate

# Or redeploy
railway up --detach
```

#### Issue 2: "Null value in column id" Errors

**Symptoms:**
- Users can't sign up
- Creating records fails with null id error

**Diagnosis:**
```bash
railway run rails runner "
  result = ActiveRecord::Base.connection.execute(
    \"SELECT column_default FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'id'\"
  ).first
  puts result['column_default']
"
```

**Solution:**
```bash
# Fix ID defaults
railway run rails db:ensure_id_defaults

# Restart app
railway up --detach
```

#### Issue 3: Database Connection Timeout

**Symptoms:**
- App fails to start with "could not connect to database"
- Health checks return 503

**Diagnosis:**
```bash
# Check if database is running
railway status

# Check database logs
railway logs --service postgresql
```

**Solution:**
```bash
# Restart database
railway restart --service postgresql

# Wait and restart app
sleep 30
railway restart
```

#### Issue 4: Schema Migrations Table Missing

**Symptoms:**
- Deployment fails with "relation schema_migrations does not exist"

**Diagnosis:**
```bash
railway run rails runner "
  puts ActiveRecord::Base.connection.table_exists?('schema_migrations')
"
```

**Solution:**
```bash
# Run repair task
railway run rails db:repair

# Restart app
railway up --detach
```

#### Issue 5: Pending Migrations After Deploy

**Symptoms:**
- App deploys but features don't work
- Logs show "pending migrations found" but no migration ran

**Diagnosis:**
```bash
railway run rails db:migrate:status
```

**Solution:**
```bash
# Force migration
railway run rails db:migrate

# If that fails, try repair
railway run rails db:repair

# Restart app
railway up --detach
```

---

## Emergency Procedures

### Emergency Database Repair

If the database is in a corrupted state:

```bash
# Step 1: Check current status
railway run rails db:deployment_status

# Step 2: Run repair task
railway run rails db:repair

# Step 3: Verify integrity
railway run rails db:verify_integrity

# Step 4: Restart app
railway restart
```

### Rolling Back a Bad Deployment

If a deployment causes issues:

```bash
# Option 1: Rollback to previous deployment in Railway UI
# Go to Deployments tab, find previous successful deployment, click "Redeploy"

# Option 2: Revert code and redeploy
git revert HEAD
git push

# Option 3: Rollback database migration
railway run rails db:rollback
railway restart
```

### Database Backup and Restore

**Backup:**
```bash
# Backup database
railway run pg_dump > backup_$(date +%Y%m%d_%H%M%S).sql
```

**Restore:**
```bash
# Restore from backup
cat backup_20260108_120000.sql | railway run psql
```

### Emergency: Complete Database Reset

**WARNING: This will DELETE ALL DATA. Only use if absolutely necessary.**

```bash
# Step 1: Backup data first
railway run pg_dump > emergency_backup.sql

# Step 2: Set RESET_DATABASE environment variable
railway variables --set "RESET_DATABASE=true"

# Step 3: Redeploy
railway up --detach

# Step 4: Monitor logs
railway logs

# Step 5: Remove RESET_DATABASE variable
railway variables --set "RESET_DATABASE="

# Step 6: Verify app is working
curl https://your-app.railway.app/health/detailed
```

---

## Maintenance Tasks

### Check Database Status

```bash
# Quick status check
railway run rails db:deployment_status

# Detailed health check
curl https://your-app.railway.app/health/detailed
```

### View Migration Status

```bash
# List all migrations and their status
railway run rails db:migrate:status
```

### Verify Database Integrity

```bash
# Run integrity checks
railway run rails db:verify_integrity
```

### Fix ID Sequence Defaults

```bash
# Ensure all ID columns have proper defaults (idempotent)
railway run rails db:ensure_id_defaults
```

### Run Pending Migrations Manually

```bash
# Run all pending migrations
railway run rails db:migrate

# Run specific migration
railway run rails db:migrate:up VERSION=20260108120000

# Rollback last migration
railway run rails db:rollback

# Rollback to specific version
railway run rails db:migrate:down VERSION=20260108120000
```

### Database Console Access

```bash
# Open Rails console
railway run rails console

# Open PostgreSQL console
railway run psql
```

### View Application Logs

```bash
# Stream logs in real-time
railway logs

# View recent logs
railway logs --limit 100

# Filter logs
railway logs | grep ERROR
```

---

## Best Practices

### 1. Always Test Migrations Locally First

```bash
# Test in development
rails db:migrate
rails db:rollback
rails db:migrate

# Test in a Railway preview environment
railway environment create preview
railway up --detach --environment preview
```

### 2. Monitor Deployments

Always watch logs during deployment:

```bash
railway logs --follow
```

### 3. Use Health Checks Proactively

Set up external monitoring:

```bash
# Add to your monitoring service (e.g., UptimeRobot, Pingdom)
https://your-app.railway.app/health/ready
```

### 4. Keep Schema.rb Up to Date

After running migrations locally, always commit updated schema.rb:

```bash
rails db:migrate
git add db/schema.rb db/migrate/
git commit -m "Add migration for new feature"
```

### 5. Document Complex Migrations

Add comments to migrations explaining what they do and why:

```ruby
class AddComplexFeature < ActiveRecord::Migration[7.1]
  # This migration adds support for X feature
  # It modifies Y table to include Z
  # Run time estimate: ~30 seconds on 1M rows

  def change
    # ...
  end
end
```

### 6. Never Edit schema.rb Manually

Always use migrations. The only exception is updating the version number after a migration that doesn't change the schema (like the ID defaults fix).

### 7. Test Recovery Procedures

Periodically test your recovery procedures in a preview environment:

```bash
# Create test environment
railway environment create recovery-test

# Deploy
railway up --detach --environment recovery-test

# Test repair
railway run rails db:repair --environment recovery-test

# Clean up
railway environment delete recovery-test
```

---

## Summary of Changes

This solution improves Railway deployments by:

### 1. **Intelligent Database Initialization** (`/bin/docker-entrypoint`)
   - Detects database state automatically
   - Chooses appropriate initialization strategy
   - Handles edge cases (partial migrations, corruption)
   - Never gets stuck in loops
   - Preserves user data

### 2. **Idempotent Maintenance Tasks** (`/lib/tasks/database_deployment.rake`)
   - `db:ensure_id_defaults` - Fixes sequence defaults safely
   - `db:verify_integrity` - Validates database health
   - `db:repair` - Emergency repair procedure
   - `db:deployment_status` - Shows current state
   - All tasks can run multiple times safely

### 3. **Comprehensive Health Checks** (`/app/controllers/health_controller.rb`)
   - Simple uptime check at `/health`
   - Detailed diagnostics at `/health/detailed`
   - Readiness probe at `/health/ready`
   - Liveness probe at `/health/live`

### 4. **Updated Schema** (`/db/schema.rb`)
   - Version updated to include latest migration
   - Ensures fresh deploys have all fixes

### 5. **Clear Documentation** (this file)
   - Complete deployment workflow
   - Troubleshooting guide
   - Emergency procedures
   - Best practices

---

## Why This Solution is Bulletproof

### 1. **Idempotency**
Every operation can run multiple times without breaking:
- Database checks use SELECT statements (read-only)
- ID default fixes use `ALTER TABLE ... SET DEFAULT` (idempotent)
- Migration tracking in schema_migrations prevents re-running
- Health checks are stateless

### 2. **Self-Healing**
The system automatically detects and fixes issues:
- Missing ID defaults → Fixed by `db:ensure_id_defaults`
- Missing schema_migrations → Created by repair task
- Partial migrations → Completed by repair task
- Database not ready → Waits up to 60 seconds with retry

### 3. **Data Preservation**
Never drops or loses data:
- Uses `db:migrate`, never `db:reset` or `db:drop`
- Repair uses `db:schema:load` only on empty databases
- All changes are additive (ALTER ADD, not DROP)
- Explicit check before any destructive operation

### 4. **Clear Visibility**
Know exactly what's happening:
- Color-coded logs (blue=info, green=success, yellow=warning, red=error)
- Structured logging with sections
- Health check endpoints for monitoring
- deployment_status task for manual inspection

### 5. **Railway Best Practices**
Follows Railway's recommendations:
- Uses official PostgreSQL plugin
- Handles SIGTERM gracefully
- Provides health check endpoints
- Uses buildpacks/Dockerfile builder
- Supports zero-downtime deployments

---

## Support and Resources

- **Railway Documentation**: https://docs.railway.app/
- **Rails Guides**: https://guides.rubyonrails.org/
- **This Project**: See other documentation files in repo root

---

**End of Guide**
