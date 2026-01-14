# Railway Deployment - Quick Reference

**For detailed information, see [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md)**

---

## Common Commands

### Deploy Application
```bash
git push                    # Auto-deploys to Railway
railway up --detach         # Manual deploy
```

### Check Status
```bash
railway logs                           # View logs
railway status                         # Service status
curl YOUR_URL/health/detailed          # Detailed health check
railway run rails db:deployment_status # Database status
```

### Database Operations
```bash
railway run rails db:migrate           # Run migrations
railway run rails db:ensure_id_defaults # Fix ID sequences
railway run rails db:verify_integrity  # Check database health
railway run rails db:deployment_status # Show status
```

### Troubleshooting
```bash
railway run rails db:repair            # Emergency repair
railway restart                        # Restart app
railway logs | grep ERROR              # Find errors
```

---

## Health Check Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/up` | Basic uptime check |
| `/health` | Simple health check with timestamp |
| `/health/detailed` | Full diagnostics with DB checks |
| `/health/ready` | Readiness probe for load balancers |
| `/health/live` | Liveness probe for orchestration |

---

## When Things Go Wrong

### User Signup Fails (Null ID Error)
```bash
railway run rails db:ensure_id_defaults
railway restart
```

### Migrations Not Running
```bash
railway run rails db:migrate
railway restart
```

### Database Seems Corrupted
```bash
railway run rails db:repair
railway run rails db:verify_integrity
railway restart
```

### Complete Reset (DANGER: Deletes all data)
```bash
# Backup first!
railway run pg_dump > backup.sql

# Set reset flag
railway variables --set "RESET_DATABASE=true"
railway up --detach

# Watch logs
railway logs --follow

# Remove reset flag
railway variables --set "RESET_DATABASE="
```

---

## Decision Tree

```
Is app working?
├─ YES → You're done!
└─ NO
   ├─ Can't connect to DB?
   │  └─ Run: railway restart --service postgresql
   │
   ├─ Null ID errors?
   │  └─ Run: railway run rails db:ensure_id_defaults
   │
   ├─ Migrations not applied?
   │  └─ Run: railway run rails db:migrate
   │
   └─ Database corrupted?
      └─ Run: railway run rails db:repair
```

---

## Files Modified

- `/bin/docker-entrypoint` - Intelligent database initialization
- `/lib/tasks/database_deployment.rake` - Maintenance tasks
- `/app/controllers/health_controller.rb` - Health checks
- `/config/routes.rb` - Health check routes
- `/db/schema.rb` - Updated to latest version

---

## What Makes This Bulletproof

1. **Idempotent** - Can run multiple times safely
2. **Self-Healing** - Automatically fixes common issues
3. **Data-Safe** - Never drops or loses user data
4. **Clear Logging** - Know exactly what's happening
5. **Railway-Optimized** - Follows all best practices

---

## Environment Variables

### Required
- `DATABASE_URL` - Auto-set by Railway PostgreSQL plugin
- `RAILS_ENV=production` - Set automatically
- `RAILS_MASTER_KEY` - Your credentials master key

### Optional
- `RESET_DATABASE=true` - Emergency reset (deletes all data)

---

## Key Rake Tasks

| Task | Purpose | Safe to Run Multiple Times? |
|------|---------|------------------------------|
| `db:migrate` | Run pending migrations | Yes |
| `db:ensure_id_defaults` | Fix ID sequences | Yes |
| `db:verify_integrity` | Check database health | Yes |
| `db:deployment_status` | Show current status | Yes |
| `db:initialize_production` | First-time setup | Yes |
| `db:post_migrate` | Post-migration tasks | Yes |
| `db:repair` | Emergency repair | Yes |

---

## Support

See [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md) for:
- Detailed troubleshooting
- Emergency procedures
- Best practices
- Complete documentation
