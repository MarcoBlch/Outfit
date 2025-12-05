# Outfit Maker: Project Status & Navigation

## Quick Overview

**Status**: Phase 1 Ready to Start (Context-Based Recommendations)
**Tech Stack**: Rails 7 + Hotwire + Tailwind CSS v4 + Vertex AI Gemini 2.5
**Business Model**: SaaS (Free / $7.99 / $14.99 per month)
**Target**: $10k MRR by Week 41

---

## Documentation Index

### 📋 Planning Documents

1. **[PRODUCT_ROADMAP.md](PRODUCT_ROADMAP.md)** ⭐ PRIMARY REFERENCE
   - Complete 6-phase product roadmap (Weeks 1-41)
   - Feature specifications with code examples
   - Monetization strategy integrated
   - Revenue projections and success criteria
   - **USE THIS**: For understanding what to build and when

2. **[TASKS.md](TASKS.md)**
   - Original task list from MVP development
   - ✅ Most Phase 1-2 features completed (Foundation, Wardrobe, Outfit Studio)
   - ⚠️ Some tasks incomplete (Item Details modal, Outfit Gallery)
   - **STATUS**: Partially outdated, superseded by PRODUCT_ROADMAP.md

3. **[IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)**
   - Original MVP implementation plan
   - Focused on frontend + AI auto-tagging
   - **STATUS**: Mostly complete, superseded by PRODUCT_ROADMAP.md

### 🔧 Technical Documentation

4. **[VERTEX_AI_RESOLUTION.md](VERTEX_AI_RESOLUTION.md)**
   - Documents migration from Gemini 1.5 to Gemini 2.5 (September 2025)
   - Troubleshooting guide for Vertex AI 404 errors
   - **USE THIS**: If Vertex AI integration breaks

5. **[MAINTENANCE.md](MAINTENANCE.md)**
   - Vertex AI model lifecycle management
   - How to update models when deprecations happen
   - Quarterly maintenance checklist
   - **USE THIS**: For ongoing AI model updates

### 📖 General

6. **[README.md](README.md)**
   - Placeholder, needs updating with setup instructions
   - **TODO**: Update with current tech stack and setup steps

---

## What's Been Built (Current State)

### ✅ Completed Features

1. **Foundation & Design System**
   - Tailwind CSS v4 with dark mode
   - Responsive layouts (Navbar, Flash messages)
   - UI components (Button, Card)
   - Hotwire Turbo + Stimulus setup

2. **Wardrobe Management**
   - Grid layout with filtering
   - Drag-and-drop image upload
   - Auto-tagging with Vertex AI Gemini 2.5
   - Real-time updates via Turbo Streams

3. **Outfit Studio**
   - Split-screen layout (wardrobe sidebar + canvas)
   - Drag-and-drop outfit creation
   - Save outfits with name and occasion

4. **AI Integration**
   - `ImageAnalysisService` using Gemini 2.5 Flash
   - Background job processing with Sidekiq
   - Turbo Streams for real-time feedback
   - Vector embeddings support (pgvector)

5. **Dashboard**
   - Home page with recent activity
   - Quick access to wardrobe and outfit studio

### ⚠️ Incomplete Features (From Original Plan)

1. **Item Details** (from TASKS.md #20-22)
   - Quick View modal for wardrobe items
   - Edit metadata form
   - **PRIORITY**: Low - defer until Phase 2-3

2. **Outfit Gallery** (from TASKS.md #30)
   - View all saved outfits
   - Filter by occasion/season
   - **PRIORITY**: Low - defer until Phase 2-3

3. **Modal/SlideOver Component** (from TASKS.md #11)
   - Reusable Stimulus-controlled modal
   - **PRIORITY**: Low - build when needed for Item Details

### 🚀 Next to Build (Priority Order)

**IMMEDIATE (Phase 1, Weeks 1-4)**:
1. **Context-Based Outfit Recommendations** ⭐ KILLER FEATURE
   - `OutfitSuggestionService` (new service)
   - `/outfits/suggest` endpoint + UI
   - Integration with existing Gemini API
   - Free tier: 3 suggestions/day

2. **Analytics Instrumentation**
   - Mixpanel or Plausible setup
   - Track: signups, uploads, AI suggestions, retention

3. **Wardrobe Upload Improvements**
   - Batch upload (multiple images)
   - Progress indicators
   - Better onboarding nudges

---

## Current Tech Stack

### Backend
- **Framework**: Ruby on Rails 7.x
- **Database**: PostgreSQL with pgvector extension
- **Background Jobs**: Sidekiq + Redis
- **Authentication**: Devise
- **File Storage**: ActiveStorage (ready for S3/Cloudflare R2)
- **API**: Vertex AI (Gemini 2.5 Flash, text-embedding-004)

### Frontend
- **Framework**: Hotwire (Turbo + Stimulus)
- **CSS**: Tailwind CSS v4
- **Build**: esbuild via jsbundling-rails
- **Icons**: Heroicons (via `heroicons-rails` or similar)

### Infrastructure
- **Hosting**: TBD (Railway, Heroku, or Fly.io recommended)
- **AI**: Google Cloud Vertex AI (us-central1)
- **Monitoring**: TBD (Sentry for errors, Mixpanel for analytics)

### NOT Using
- ❌ Vite (esbuild sufficient for Stimulus-light app)
- ❌ Next.js (Rails + Hotwire faster for solo dev)
- ❌ React/Vue (Stimulus + Turbo Frames sufficient)
- ❌ Custom virtual try-on model (using FASHN API in Phase 4)

---

## Decision Log

### Confirmed Decisions

1. **Tech Stack**: Stick with Rails + Hotwire
   - **Reasoning**: Already working, faster than Next.js migration, perfect for this use case
   - **Date**: 2025-12-04

2. **NO Vite Integration**
   - **Reasoning**: esbuild sufficient, Vite adds complexity for minimal benefit
   - **Date**: 2025-12-04

3. **Virtual Try-On via FASHN API (NOT custom model)**
   - **Reasoning**: $0.04-0.075/image cheaper than building ($50k-250k), professional quality
   - **Date**: 2025-12-04

4. **Monetization Model**: 3-tier SaaS (Free / $7.99 / $14.99)
   - **Reasoning**: Premium AI positioning, 60-200% above competitors justified
   - **Date**: 2025-12-04

5. **Phase 1 Focus**: Context-based outfit recommendations
   - **Reasoning**: Killer feature, leverages existing AI, clear user value
   - **Date**: 2025-12-04

### Open Questions

1. **When to launch Premium tier?**
   - **Current Plan**: Week 9 (Phase 3)
   - **Condition**: Must hit 200+ users, 50%+ Week 1 retention first

2. **Mobile strategy?**
   - **Current Plan**: PWA in Phase 2, native app only if PWA adoption <50%
   - **Decision Date**: TBD after 6 months

3. **Hosting platform?**
   - **Options**: Railway (simplest), Heroku (familiar), Fly.io (cost-effective)
   - **Decision Date**: Before Phase 1 launch

---

## Success Metrics (Current Targets)

### Phase 1 Success Criteria (Before Phase 2)
- ✅ 200+ weekly active users
- ✅ 60%+ users upload 10+ items
- ✅ 50%+ Week 1 retention
- ✅ 5+ AI suggestions per engaged user per week
- ✅ NPS > 40

### Phase 3 Success Criteria (Before Phase 4)
- ✅ 50+ paying Premium customers
- ✅ 4-6% free → premium conversion
- ✅ $400-500 MRR
- ✅ <10% monthly churn
- ✅ 1,000+ total users

### Phase 5 Success Criteria (Before Phase 6)
- ✅ $5,000 MRR
- ✅ 600 Premium + 40 Pro subscribers
- ✅ 8%+ free → premium conversion
- ✅ <6% monthly churn
- ✅ 10,000+ total users

### Ultimate Goal (Month 8-9)
- ✅ $10,000 MRR
- ✅ 1,150 Premium + 100 Pro subscribers
- ✅ 20,000+ total users
- ✅ Product-market fit validated

---

## Immediate Next Steps (This Week)

### Step 1: Review Phase 1 Spec (Day 1)
- Read [PRODUCT_ROADMAP.md](PRODUCT_ROADMAP.md) Phase 1 section
- Understand `OutfitSuggestionService` architecture
- Review existing Gemini integration in `app/services/image_analysis_service.rb`

### Step 2: Build OutfitSuggestionService (Days 2-4)
- Create service class with Gemini prompt engineering
- Implement wardrobe inventory summarization
- Add JSON parsing and validation
- Test with sample wardrobe data

### Step 3: Build UI (Days 5-7)
- Create `/outfits/suggest` route and controller
- Build context input form (simple text area)
- Create suggestions results view (3 cards with outfit combinations)
- Add "Get Suggestions" CTA to dashboard

### Step 4: Implement Rate Limiting (Day 8)
- Track AI suggestion usage per user per day
- Enforce 3/day limit for free tier
- Show upgrade prompt when limit reached (even though Premium doesn't exist yet)

### Step 5: Beta Test (Days 9-14)
- Invite 20 beta users (friends, family, fashion-conscious network)
- Gather feedback via user interviews
- Iterate on suggestion quality
- Measure retention: Do they return in Week 2-4?

---

## Key Files to Know

### Services
- `app/services/image_analysis_service.rb` - Gemini 2.5 integration (working)
- `app/services/embedding_service.rb` - Text embeddings (working with text-embedding-004)
- `app/services/outfit_suggestion_service.rb` - ⚠️ TO BE BUILT (Phase 1)
- `app/services/wardrobe_search_service.rb` - ⚠️ TO BE BUILT (Phase 3)
- `app/services/virtual_tryon_service.rb` - ⚠️ TO BE BUILT (Phase 4)

### Jobs
- `app/jobs/image_analysis_job.rb` - Background AI tagging (working)
- `app/jobs/outfit_suggestion_job.rb` - ⚠️ TO BE BUILT (Phase 2)
- `app/jobs/daily_outfit_suggestion_job.rb` - ⚠️ TO BE BUILT (Phase 3)

### Controllers
- `app/controllers/wardrobe_items_controller.rb` - Wardrobe management (working)
- `app/controllers/outfits_controller.rb` - Outfit studio (working)
- `app/controllers/outfit_suggestions_controller.rb` - ⚠️ TO BE BUILT (Phase 1)

### Models
- `app/models/user.rb` - User accounts (Devise)
- `app/models/wardrobe_item.rb` - Clothing items with embeddings
- `app/models/outfit.rb` - Saved outfits
- `app/models/user_profile.rb` - ⚠️ TO BE BUILT (Phase 2)
- `app/models/subscription.rb` - ⚠️ TO BE BUILT (Phase 3)

---

## Environment Variables Needed

### Current (Working)
```env
GOOGLE_CLOUD_PROJECT=project-a93d3874-a9c7-43f9-979
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
REDIS_URL=redis://localhost:6379/1
DATABASE_URL=postgresql://...
```

### Future (Phase 3+)
```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
OPENWEATHER_API_KEY=...
MIXPANEL_TOKEN=...
```

### Future (Phase 4+)
```env
FASHN_API_KEY=...
```

### Future (Phase 5+)
```env
AMAZON_AFFILIATE_KEY=...
NORDSTROM_AFFILIATE_KEY=...
ASOS_AFFILIATE_KEY=...
```

---

## Git Workflow Recommendations

### Branch Strategy
```bash
# Main branch: production-ready code
main

# Development branches (feature-based)
feature/outfit-recommendations
feature/user-profiles
feature/weather-integration
feature/stripe-integration
feature/virtual-tryon

# Hotfix branches
hotfix/vertex-ai-timeout
hotfix/upload-bug
```

### Commit Message Style
```bash
feat: Add context-based outfit recommendations
fix: Resolve image upload timeout for large files
refactor: Extract Gemini prompt logic to separate class
docs: Update PRODUCT_ROADMAP with Phase 4 details
chore: Upgrade Rails to 7.2.1
```

---

## When Things Break

### Vertex AI 404 Errors
**See**: [VERTEX_AI_RESOLUTION.md](VERTEX_AI_RESOLUTION.md)

**Quick Fix**:
1. Check if model is deprecated: [Vertex AI Model Versions](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions)
2. Update model ID in `app/services/image_analysis_service.rb`
3. Run verification: `ruby scripts/verify/verify_vision_api.rb`

### Sidekiq Jobs Stuck
**Quick Fix**:
```bash
# Check Sidekiq queue
bundle exec sidekiq

# Clear stuck jobs (use carefully!)
Sidekiq::Queue.new.clear
```

### Tailwind Styles Not Updating
**Quick Fix**:
```bash
# Rebuild CSS
bin/rails assets:precompile

# Or restart dev server with asset watching
bin/dev
```

---

## Resources & References

### Product Strategy
- PM Agent's monetization analysis (above)
- Competitor analysis: Stylebook ($4.99), Cladwell ($5), Pureple ($3.99)
- Target user: Fashion-conscious professionals, 25-45, $8-15/mo budget

### Technical References
- [Vertex AI Gemini API](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini)
- [FASHN API Docs](https://docs.fashn.ai/)
- [Hotwire Handbook](https://hotwired.dev/)
- [Tailwind CSS v4](https://tailwindcss.com/docs)

### Inspiration
- AI-powered recommendations: Stitch Fix, Rent the Runway
- Wardrobe management: Stylebook, Cladwell
- Virtual try-on: FASHN, Pixelcut

---

## Questions or Stuck?

### For Product Decisions
**Reference**: [PRODUCT_ROADMAP.md](PRODUCT_ROADMAP.md)
**Ask**: "Will this feature help users solve 'What should I wear today?' faster?"

### For Technical Implementation
**Check**: Existing services in `app/services/`
**Pattern**: Follow `ImageAnalysisService` structure for new AI integrations

### For Monetization Strategy
**Reference**: PM Agent analysis (in this conversation)
**Key Principle**: Charge for value delivered, not cost incurred

---

**Status as of 2025-12-04**: Ready to start Phase 1 (Context-Based Recommendations)

**Next Git Branch**: `feature/outfit-recommendations`

**Next Commit**: `feat: Add OutfitSuggestionService with Gemini integration`
