# Project Cleanup Report

**Date**: 2026-01-13
**Context**: Pre-Launch (Week 0) - Focus on 6-week launch plan

---

## Executive Summary

Found **34 markdown files** in project root and `/docs/`. **19 files recommended for deletion** as they're outdated, superseded, or no longer relevant to the Week 0-6 launch focus.

**Recommended Action**: Move outdated files to `/archive/` folder instead of deleting (safer, allows recovery if needed).

---

## Files to KEEP (Essential for Week 0-6 Launch)

### Launch Planning & Guides (Created Jan 12-13, 2026)
✅ **[PRE_LAUNCH_PLAN.md](PRE_LAUNCH_PLAN.md)** - Master 6-week roadmap
✅ **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** - Week 1 action plan
✅ **[docs/ANALYTICS_SETUP_GUIDE.md](docs/ANALYTICS_SETUP_GUIDE.md)** - Plausible setup
✅ **[docs/EMAIL_SETUP_GUIDE.md](docs/EMAIL_SETUP_GUIDE.md)** - Mailgun configuration
✅ **[docs/LANDING_PAGE_IMPLEMENTATION.md](docs/LANDING_PAGE_IMPLEMENTATION.md)** - Remove login wall
✅ **[docs/METRICS_TRACKING_TEMPLATE.csv](docs/METRICS_TRACKING_TEMPLATE.csv)** - Google Sheets template

### Product Strategy
✅ **[PRODUCT_ROADMAP_v2.md](PRODUCT_ROADMAP_v2.md)** - Complete product vision, tech stack, Phase 4 details
✅ **[README.md](README.md)** - Project README (needs updating but keep)

### Deployment & Infrastructure
✅ **[NEXT_STEPS.md](NEXT_STEPS.md)** - Railway deployment checklist (still relevant)
✅ **[API_KEYS_SETUP.md](API_KEYS_SETUP.md)** - API keys reference
✅ **[RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md)** - Deployment guide

### Technical Reference
✅ **[VERTEX_AI_RESOLUTION.md](VERTEX_AI_RESOLUTION.md)** - Gemini AI troubleshooting
✅ **[MAINTENANCE.md](MAINTENANCE.md)** - AI model lifecycle management
✅ **[docs/SETUP_BACKGROUND_REMOVAL.md](docs/SETUP_BACKGROUND_REMOVAL.md)** - Background removal setup

---

## Files to ARCHIVE (Outdated/Superseded)

### Old Implementation Plans (Superseded by PRE_LAUNCH_PLAN.md)
❌ **[CURRENT_IMPLEMENTATION_PLAN.md](CURRENT_IMPLEMENTATION_PLAN.md)**
   - **Why**: Admin dashboard + soft ads plan from Dec 11
   - **Superseded by**: PRE_LAUNCH_PLAN.md (focus on core launch, defer admin)
   - **Last Updated**: Dec 11, 2025

❌ **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)**
   - **Why**: Original MVP implementation plan
   - **Superseded by**: PRODUCT_ROADMAP_v2.md + PRE_LAUNCH_PLAN.md
   - **Status**: Mostly complete

❌ **[TASKS.md](TASKS.md)**
   - **Why**: Original task list from MVP development
   - **Status**: Partially outdated, most tasks complete
   - **Superseded by**: PRE_LAUNCH_PLAN.md

❌ **[PROJECT_STATUS.md](PROJECT_STATUS.md)**
   - **Why**: Navigation doc pointing to old plans
   - **Last Updated**: Dec 4, 2025
   - **Superseded by**: PRE_LAUNCH_PLAN.md + QUICK_START_GUIDE.md

### Old Product Roadmap (v1)
❌ **[PRODUCT_ROADMAP.md](PRODUCT_ROADMAP.md)**
   - **Why**: Version 1 roadmap
   - **Superseded by**: PRODUCT_ROADMAP_v2.md
   - **Note**: v2 has updated revenue projections and Phase 4 details

### Monetization (Covered in PRODUCT_ROADMAP_v2.md)
❌ **[MONETIZATION_STRATEGY.md](MONETIZATION_STRATEGY.md)**
   - **Why**: Standalone monetization doc
   - **Superseded by**: PRODUCT_ROADMAP_v2.md (includes full monetization strategy)

### Competitive Research (One-time analysis)
❌ **[COMPETITIVE_RESEARCH.md](COMPETITIVE_RESEARCH.md)**
   - **Why**: Initial competitor analysis
   - **Status**: Useful reference but not needed for Week 0-6 launch

### Admin Dashboard (Phase 3B - Defer until Month 6+)
❌ **[ADMIN_BACKEND_COMPLETE.md](ADMIN_BACKEND_COMPLETE.md)**
❌ **[ADMIN_BACKEND_IMPLEMENTATION.md](ADMIN_BACKEND_IMPLEMENTATION.md)**
❌ **[ADMIN_DASHBOARD_COMPLETE.md](ADMIN_DASHBOARD_COMPLETE.md)**
❌ **[ADMIN_DASHBOARD_SHOWCASE.md](ADMIN_DASHBOARD_SHOWCASE.md)**
❌ **[ADMIN_DASHBOARD_UI.md](ADMIN_DASHBOARD_UI.md)**
❌ **[ADMIN_DASHBOARD_VISUAL_GUIDE.md](ADMIN_DASHBOARD_VISUAL_GUIDE.md)**
❌ **[docs/ADMIN_DASHBOARD_SPECS.md](docs/ADMIN_DASHBOARD_SPECS.md)**
❌ **[db/ADMIN_DATABASE_IMPLEMENTATION.md](db/ADMIN_DATABASE_IMPLEMENTATION.md)**
❌ **[db/ADMIN_QUERY_OPTIMIZATION.md](db/ADMIN_QUERY_OPTIMIZATION.md)**
   - **Why**: Admin dashboard was built but deferred per PRE_LAUNCH_PLAN.md
   - **Decision**: Not needed until Month 6+ (after 200+ users)
   - **Note**: Keep for reference but archive

### Deployment Issues (Historical/Resolved)
❌ **[RAILWAY_SNAPSHOT_FIX.md](RAILWAY_SNAPSHOT_FIX.md)**
   - **Why**: Railway snapshot timeout fix (already applied)
   - **Status**: Historical reference only

❌ **[RAILWAY_DEPLOYMENT_FIX.md](RAILWAY_DEPLOYMENT_FIX.md)**
   - **Why**: Deployment fix documentation
   - **Status**: Issues resolved, covered in RAILWAY_DEPLOYMENT_GUIDE.md

❌ **[DEPLOYMENT_QUICK_REFERENCE.md](DEPLOYMENT_QUICK_REFERENCE.md)**
   - **Why**: Quick reference
   - **Superseded by**: RAILWAY_DEPLOYMENT_GUIDE.md

❌ **[DEPLOYMENT_SOLUTION_EXPLAINED.md](DEPLOYMENT_SOLUTION_EXPLAINED.md)**
   - **Why**: Deployment troubleshooting
   - **Superseded by**: RAILWAY_DEPLOYMENT_GUIDE.md

❌ **[DNS_SETUP_GUIDE.md](DNS_SETUP_GUIDE.md)**
   - **Why**: DNS configuration
   - **Covered in**: NEXT_STEPS.md

❌ **[DIAGNOSIS_AND_FIX.md](DIAGNOSIS_AND_FIX.md)**
   - **Why**: Generic troubleshooting doc
   - **Status**: Historical

### Phase 4 Implementation (Already Complete)
❌ **[PHASE_4_DEPLOYMENT.md](PHASE_4_DEPLOYMENT.md)**
❌ **[PHASE_4_IMPLEMENTATION_SUMMARY.md](PHASE_4_IMPLEMENTATION_SUMMARY.md)**
❌ **[PHASE_4_TEST_RESULTS.md](PHASE_4_TEST_RESULTS.md)**
   - **Why**: Phase 4 already deployed and working
   - **Status**: Historical reference only

### Implementation Summaries (Historical)
❌ **[CHUNK4_IMPLEMENTATION_SUMMARY.md](CHUNK4_IMPLEMENTATION_SUMMARY.md)**
❌ **[FRONTEND_IMPLEMENTATION_SUMMARY.md](FRONTEND_IMPLEMENTATION_SUMMARY.md)**
❌ **[IMPLEMENTATION_CHUNK2_SUMMARY.md](IMPLEMENTATION_CHUNK2_SUMMARY.md)**
   - **Why**: Historical implementation notes
   - **Status**: Features already built, summaries not needed

---

## Recommended Actions

### Step 1: Create Archive Folder
```bash
mkdir -p archive/admin_dashboard
mkdir -p archive/deployment_fixes
mkdir -p archive/implementation_history
mkdir -p archive/old_plans
```

### Step 2: Move Files to Archive

**Admin Dashboard** (9 files):
```bash
mv ADMIN_*.md archive/admin_dashboard/
mv docs/ADMIN_DASHBOARD_SPECS.md archive/admin_dashboard/
mv db/ADMIN_*.md archive/admin_dashboard/
```

**Deployment Fixes** (5 files):
```bash
mv RAILWAY_SNAPSHOT_FIX.md archive/deployment_fixes/
mv RAILWAY_DEPLOYMENT_FIX.md archive/deployment_fixes/
mv DEPLOYMENT_*.md archive/deployment_fixes/
mv DIAGNOSIS_AND_FIX.md archive/deployment_fixes/
mv DNS_SETUP_GUIDE.md archive/deployment_fixes/
```

**Implementation History** (6 files):
```bash
mv PHASE_4_*.md archive/implementation_history/
mv *IMPLEMENTATION_SUMMARY.md archive/implementation_history/
mv *CHUNK*.md archive/implementation_history/
```

**Old Plans** (5 files):
```bash
mv CURRENT_IMPLEMENTATION_PLAN.md archive/old_plans/
mv IMPLEMENTATION_PLAN.md archive/old_plans/
mv TASKS.md archive/old_plans/
mv PROJECT_STATUS.md archive/old_plans/
mv PRODUCT_ROADMAP.md archive/old_plans/  # Keep v2 only
mv MONETIZATION_STRATEGY.md archive/old_plans/
mv COMPETITIVE_RESEARCH.md archive/old_plans/
```

### Step 3: Clean Project Root

**After archiving, your project root will have**:
- [PRE_LAUNCH_PLAN.md](PRE_LAUNCH_PLAN.md) ⭐ PRIMARY
- [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) ⭐ WEEK 1
- [PRODUCT_ROADMAP_v2.md](PRODUCT_ROADMAP_v2.md) ⭐ PRODUCT VISION
- [README.md](README.md)
- [NEXT_STEPS.md](NEXT_STEPS.md)
- [API_KEYS_SETUP.md](API_KEYS_SETUP.md)
- [RAILWAY_DEPLOYMENT_GUIDE.md](RAILWAY_DEPLOYMENT_GUIDE.md)
- [VERTEX_AI_RESOLUTION.md](VERTEX_AI_RESOLUTION.md)
- [MAINTENANCE.md](MAINTENANCE.md)

**docs/ folder will have**:
- [docs/ANALYTICS_SETUP_GUIDE.md](docs/ANALYTICS_SETUP_GUIDE.md)
- [docs/EMAIL_SETUP_GUIDE.md](docs/EMAIL_SETUP_GUIDE.md)
- [docs/LANDING_PAGE_IMPLEMENTATION.md](docs/LANDING_PAGE_IMPLEMENTATION.md)
- [docs/METRICS_TRACKING_TEMPLATE.csv](docs/METRICS_TRACKING_TEMPLATE.csv)
- [docs/SETUP_BACKGROUND_REMOVAL.md](docs/SETUP_BACKGROUND_REMOVAL.md)

---

## Summary

**Total Files Analyzed**: 34
**Files to Keep**: 15 (44%)
**Files to Archive**: 19 (56%)

**Why Archive Instead of Delete**:
- Safe recovery if needed later
- Historical reference for decisions
- May be useful in Month 6+ (admin dashboard, etc.)
- Keeps git history clean

**Impact**:
- ✅ Cleaner project structure
- ✅ Focus on Week 0-6 priorities
- ✅ Easy to find current documentation
- ✅ No risk of losing important info

---

## Next Step

Run the cleanup script or manually execute the move commands above.

**Estimated time**: 2 minutes
