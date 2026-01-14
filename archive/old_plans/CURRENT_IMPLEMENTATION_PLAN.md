# Current Implementation Plan
## Admin Dashboard + Soft Ads

**Date**: 2025-12-11
**Status**: Phase 3 Complete → Starting Phase 3B & 4

---

## ✅ Completed Phases

### Phase 1: AI Outfit Suggestions ✅
- Context-based recommendations with Gemini 2.5 Flash
- Rate limiting (3/day Free, 30/day Premium, 100/day Pro)
- Turbo Streams for real-time UI updates
- "Why this outfit?" rational explanations

### Phase 2: User Profiles & Weather ✅
- 5-question style profile
- Weather integration (all tiers)
- Profile completion tracking

### Phase 3: Stripe Subscriptions ✅
- 3-tier pricing (Free, Premium $7.99, Pro $14.99)
- Stripe Checkout integration
- Image-based wardrobe search (Premium+)
- Background removal via rembg

### Recent Fixes (Dec 11, 2025) ✅
- Profile form CSS peer selector cascade bug
- Modal close behavior after profile update
- Weather integration clarity in pricing

---

## 🎯 Current Priority: Phase 3B - Admin Dashboard

**Timeline**: 1-2 weeks
**Goal**: Enable testing Premium/Pro features + monitor user analytics

### Why Admin Dashboard First?
1. ✅ Unblocks manual testing of Premium/Pro features
2. ✅ Provides visibility into user behavior NOW
3. ✅ Required foundation for monitoring ads & try-on later
4. ✅ Helps make data-driven decisions

---

## 📋 Admin Dashboard Scope

### Core Features

#### 1. User Management
**Priority**: CRITICAL
**Assignee**: Backend Agent + Frontend Agent

**Features**:
- List all users (paginated, searchable)
- Filter by:
  - Subscription tier (Free, Premium, Pro)
  - Signup date range
  - Activity level (active, inactive, churned)
- View individual user details:
  - Email, signup date, subscription status
  - Wardrobe item count, outfit count
  - AI suggestion usage stats
  - Last login date
- **MANUAL TIER UPGRADE** (for testing!):
  - Button: "Upgrade to Premium/Pro"
  - No Stripe charge, just changes `subscription_tier`
  - Use case: Testing Premium/Pro features without payment

**Technical Approach**:
```ruby
# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::BaseController
  def index
    @users = User.includes(:user_profile, :wardrobe_items, :outfits)
                 .page(params[:page])
                 .per(50)
  end

  def update_tier
    @user = User.find(params[:id])
    @user.update!(subscription_tier: params[:tier])
    redirect_to admin_user_path(@user), notice: "Tier updated to #{params[:tier]}"
  end
end
```

**UI Components**:
- Users table with search/filter
- User detail page with stats cards
- Tier upgrade dropdown + button
- Activity timeline

---

#### 2. Subscription Metrics Dashboard
**Priority**: HIGH
**Assignee**: Backend Agent + Frontend Agent

**Metrics to Display**:

**Revenue Metrics**:
- MRR (Monthly Recurring Revenue)
  - Total MRR
  - Breakdown by tier (Free: $0, Premium: $XXX, Pro: $XXX)
- Total paying customers
- Conversion rate (Free → Premium, Premium → Pro)
- Average Revenue Per User (ARPU)

**Subscription Health**:
- Active subscriptions by tier (pie chart)
- New subscriptions this month
- Cancellations this month
- Churn rate (monthly)
- Reactivations

**Cohort Analysis**:
- Signups by week/month
- Retention by cohort (Day 7, 30, 90)

**Technical Approach**:
```ruby
# app/models/analytics/subscription_metrics.rb
class Analytics::SubscriptionMetrics
  def mrr
    {
      total: calculate_total_mrr,
      premium: User.premium.count * 7.99,
      pro: User.pro.count * 14.99
    }
  end

  def conversion_rates
    {
      free_to_premium: (User.premium.count.to_f / User.count * 100).round(2),
      premium_to_pro: (User.pro.count.to_f / User.premium_or_pro.count * 100).round(2)
    }
  end

  def churn_rate(period: 1.month)
    # Calculate based on Stripe webhook events
  end
end
```

**UI Components**:
- KPI cards (MRR, Total Users, Paying %, Churn)
- Line charts (MRR over time, signups over time)
- Pie chart (users by tier)
- Tables (recent upgrades, recent cancellations)

---

#### 3. Usage Analytics
**Priority**: HIGH
**Assignee**: Backend Agent + Database Agent

**Metrics to Track**:

**AI Usage**:
- Total outfit suggestions generated
- Suggestions per day/week/month (line chart)
- Average suggestions per user
- Peak usage times (heatmap)
- Most common contexts ("date night", "job interview", etc.)

**API Costs**:
- Gemini API calls per day
- Estimated cost per call ($0.01)
- Total monthly AI cost
- Cost per user tier
- Alert: Red flag if >$500/month

**Feature Usage**:
- Image searches performed (Premium+)
- Background removals processed
- Outfits created on canvas
- Wardrobe items uploaded per day

**Technical Approach**:
```ruby
# app/models/analytics/usage_metrics.rb
class Analytics::UsageMetrics
  def ai_suggestions_stats
    {
      total_today: OutfitSuggestion.today.count,
      total_this_week: OutfitSuggestion.this_week.count,
      total_this_month: OutfitSuggestion.this_month.count,
      avg_per_user: OutfitSuggestion.count.to_f / User.count
    }
  end

  def estimated_ai_cost
    OutfitSuggestion.this_month.count * 0.01
  end

  def top_contexts(limit: 10)
    OutfitSuggestion.group(:context).count.sort_by { |_, v| -v }.first(limit)
  end
end
```

**Database Requirements**:
```ruby
# Track API costs
class OutfitSuggestion < ApplicationRecord
  # Add column: api_cost (decimal)
  # Add column: context (text) - already exists

  scope :today, -> { where('created_at >= ?', Date.today) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
end
```

**UI Components**:
- KPI cards (total suggestions, monthly cost, avg/user)
- Line chart (suggestions over time)
- Heatmap (peak usage hours)
- Top contexts table
- Cost alerts (red banner if >$500/month)

---

#### 4. Admin Authentication
**Priority**: CRITICAL
**Assignee**: Backend Agent

**Requirements**:
- Protect admin routes with `admin?` flag
- Only allow specific emails to be admin
- Secure session management

**Technical Approach**:
```ruby
# Add column to users table
rails g migration AddAdminToUsers admin:boolean
# Default: false

# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Access denied"
    end
  end
end

# Set admin flag via console
User.find_by(email: 'your@email.com').update(admin: true)
```

**Routes**:
```ruby
# config/routes.rb
namespace :admin do
  root to: 'dashboard#index'
  resources :users, only: [:index, :show] do
    member do
      patch :update_tier
    end
  end
  get 'metrics/subscriptions', to: 'metrics#subscriptions'
  get 'metrics/usage', to: 'metrics#usage'
end
```

---

### Admin Dashboard UI Design

**Layout**:
```
+----------------------------------------------------------+
|  Admin Panel                                   Logout    |
+----------------------------------------------------------+
|  Dashboard | Users | Metrics | Content (future)         |
+----------------------------------------------------------+
|                                                          |
|  📊 DASHBOARD (Overview)                                 |
|                                                          |
|  +---------------+  +---------------+  +---------------+ |
|  | Total Users   |  | Paying Users  |  | MRR          | |
|  | 1,247         |  | 89 (7.1%)     |  | $714         | |
|  +---------------+  +---------------+  +---------------+ |
|                                                          |
|  +---------------+  +---------------+  +---------------+ |
|  | AI Cost       |  | Suggestions   |  | Churn Rate   | |
|  | $124/mo       |  | 3,429 total   |  | 5.2%         | |
|  +---------------+  +---------------+  +---------------+ |
|                                                          |
|  📈 MRR Over Time                                        |
|  [Line chart: Last 90 days]                             |
|                                                          |
|  👥 Recent Activity                                      |
|  - Jane Doe upgraded to Premium (2 hours ago)           |
|  - John Smith created 5 outfits (3 hours ago)           |
|                                                          |
+----------------------------------------------------------+
```

**Technology**:
- Tailwind CSS (already using)
- Heroicons for icons
- Chartkick gem for charts (or Chart.js directly)
- Turbo Frames for dynamic updates

---

## 🎯 Next Priority: Phase 4 - Soft Ads

**Timeline**: 2-3 days
**Goal**: Generate $5-50/month passive revenue from free tier

### Soft Ads Scope

#### 1. Ad Placement Strategy
**Priority**: HIGH
**Assignee**: Frontend Agent + PM Agent

**Placements** (Free tier ONLY):

**Option 1: Dashboard Banner** (Top)
- Non-intrusive horizontal banner
- 728x90 or 320x50 (responsive)
- Above "Quick Actions" section
- Clear "Ad" label for transparency

**Option 2: Between Wardrobe Items** (Subtle)
- Every 10th item in wardrobe grid
- Native ad style (looks like wardrobe item card)
- Labeled "Sponsored"

**Option 3: After Outfit Creation** (High engagement)
- Show ad in success modal after saving outfit
- "Complete the look" style ad
- Less intrusive than popup

**Recommendation**: Start with Option 1 (Dashboard Banner) - easiest, least intrusive

**UI Mock**:
```
+----------------------------------------------------------+
|  Dashboard                                               |
+----------------------------------------------------------+
|  [Ad] Google AdSense Banner (728x90)                    |
+----------------------------------------------------------+
|  Quick Actions:  [Get AI Suggestion]  [Create Outfit]   |
+----------------------------------------------------------+
```

---

#### 2. Ad Network Integration
**Priority**: HIGH
**Assignee**: Backend Agent + Frontend Agent

**Network Choice**: Google AdSense (Recommended)

**Why AdSense**:
- ✅ Easiest setup (paste code snippet)
- ✅ Auto-optimized ads (fill rate, relevance)
- ✅ Fashion-focused ads available
- ✅ Payment threshold: $100 (achievable)
- ✅ Trustworthy, reliable

**Technical Implementation**:
```erb
<!-- app/views/shared/_ad_banner.html.erb -->
<% unless current_user.premium? || current_user.pro? %>
  <div class="my-4 p-4 bg-gray-900/50 rounded-xl border border-white/10">
    <p class="text-xs text-gray-500 mb-2">Advertisement</p>

    <!-- Google AdSense -->
    <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-YOUR_ID"
         crossorigin="anonymous"></script>
    <ins class="adsbygoogle"
         style="display:block"
         data-ad-client="ca-pub-YOUR_ID"
         data-ad-slot="YOUR_SLOT_ID"
         data-ad-format="auto"
         data-full-width-responsive="true"></ins>
    <script>
         (adsbygoogle = window.adsbygoogle || []).push({});
    </script>
  </div>
<% end %>
```

**Setup Steps**:
1. Sign up for Google AdSense
2. Add site to AdSense (verify ownership)
3. Create ad unit (responsive banner)
4. Get publisher ID and slot ID
5. Add code to layout
6. Wait for approval (1-3 days)

**A/B Testing**:
- Track: Ad impressions, clicks, revenue per free user
- Goal: Optimize placement without hurting UX
- Tools: Google Analytics + AdSense reports

---

#### 3. Frequency Capping & UX
**Priority**: MEDIUM
**Assignee**: Frontend Agent

**Rules**:
- **Never** show ads to Premium/Pro users
- Dashboard: 1 banner per page load
- Wardrobe: 1 ad per 10 items (max 3 per page)
- Outfit success modal: 1 ad, closeable after 3 seconds

**User Sentiment Tracking**:
- Add feedback link: "Ads too intrusive? Upgrade to Premium"
- Monitor: Free tier churn rate after ads launch
- Red flag: If churn increases >10%

---

#### 4. Revenue Tracking
**Priority**: LOW
**Assignee**: Backend Agent

**Metrics to Track**:
```ruby
# app/models/ad_impression.rb
class AdImpression < ApplicationRecord
  belongs_to :user

  # Columns:
  # - placement (string): 'dashboard_banner', 'wardrobe_grid', 'outfit_modal'
  # - clicked (boolean)
  # - revenue (decimal) - estimated CPM
  # - created_at

  scope :today, -> { where('created_at >= ?', Date.today) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }

  def self.estimated_revenue_today
    today.sum(:revenue)
  end
end
```

**Expected Revenue**:
- 500 free users × 20 pageviews/week × $2 CPM = **$20/month**
- Scales with free user growth

---

## 📊 Success Metrics

### Admin Dashboard
- ✅ All metrics load in <2 seconds
- ✅ Can manually upgrade user to Premium/Pro in <10 seconds
- ✅ MRR calculation accurate (cross-check with Stripe)
- ✅ Usage metrics match production (no data discrepancies)

### Soft Ads
- ✅ AdSense approved and serving ads
- ✅ $5-20/month revenue in first 30 days
- ✅ Free tier churn <8% (no significant increase)
- ✅ <5% complaints about ads

---

## 🚀 Agent Task Distribution

### 🎨 Frontend Agent
**Branch**: `feature/admin-dashboard-ui`

**Tasks**:
1. Create admin dashboard layout with Tailwind
2. Build KPI cards (users, MRR, churn, AI cost)
3. Implement charts (MRR over time, users by tier)
4. User management table (search, filter, pagination)
5. User detail page with stats
6. Ad banner component (Google AdSense integration)
7. A/B test ad placements

**Deliverables**:
- `app/views/admin/dashboard/index.html.erb`
- `app/views/admin/users/index.html.erb`
- `app/views/admin/users/show.html.erb`
- `app/views/admin/metrics/subscriptions.html.erb`
- `app/views/admin/metrics/usage.html.erb`
- `app/views/shared/_ad_banner.html.erb`

---

### ⚙️ Backend Agent
**Branch**: `feature/admin-backend`

**Tasks**:
1. Add `admin` boolean to users table
2. Create `Admin::BaseController` with authentication
3. Implement `Admin::UsersController` (index, show, update_tier)
4. Implement `Admin::DashboardController` (overview metrics)
5. Implement `Admin::MetricsController` (subscriptions, usage)
6. Create analytics service classes:
   - `Analytics::SubscriptionMetrics`
   - `Analytics::UsageMetrics`
7. Create `AdImpression` model and tracking
8. Set up admin routes

**Deliverables**:
- Migration: `add_admin_to_users`
- `app/controllers/admin/*`
- `app/models/analytics/*`
- `app/models/ad_impression.rb`
- Updated routes

---

### 🗄️ Database Agent
**Branch**: `feature/admin-database`

**Tasks**:
1. Review `users` table for admin flag
2. Add indexes for admin queries:
   - `users.subscription_tier`
   - `users.created_at`
   - `outfit_suggestions.created_at`
3. Create `ad_impressions` table
4. Optimize analytics queries (aggregations, CTEs)
5. Set up database views for common reports (optional)

**Deliverables**:
- Migration: `add_admin_to_users`
- Migration: `add_indexes_for_admin_queries`
- Migration: `create_ad_impressions`
- Query optimization report

---

### 📊 PM Agent
**Branch**: `docs/admin-dashboard-specs`

**Tasks**:
1. Define admin dashboard KPIs and targets
2. Create ad placement strategy document
3. Define A/B test plan for ads
4. Prioritize metrics (must-have vs. nice-to-have)
5. Review UI mockups for UX
6. Create user testing plan

**Deliverables**:
- `docs/ADMIN_DASHBOARD_SPECS.md`
- `docs/AD_STRATEGY.md`
- KPI targets document
- Testing checklist

---

## ⏱️ Timeline

**Week 1**:
- Day 1-2: Backend (admin auth, controllers, analytics services)
- Day 3-4: Frontend (dashboard UI, user management)
- Day 5: Database (migrations, indexes)
- Day 6-7: Integration + testing

**Week 2**:
- Day 1-2: Soft ads implementation (AdSense signup, code integration)
- Day 3: A/B testing setup
- Day 4-5: Monitoring + iteration
- Day 6-7: Documentation + handoff

**Merge to master**: End of Week 2

---

## 🔄 Parallel Agent Work

**Can agents work independently?**
✅ YES! Each agent has distinct tasks with minimal overlap.

**What if one agent hits rate limit?**
✅ Other agents continue working. No blocking dependencies.

**Merge strategy**:
1. Database agent merges first (migrations)
2. Backend agent merges second (depends on migrations)
3. Frontend agent merges third (depends on backend endpoints)
4. PM agent merges docs anytime (no code dependencies)

---

## 📝 Testing Plan

### Manual Testing Checklist

**Admin Dashboard**:
- [ ] Can log in to `/admin` with admin user
- [ ] Non-admin redirected to root with error
- [ ] All metrics display correctly
- [ ] Can search/filter users
- [ ] Can manually upgrade user tier
- [ ] Charts render without errors
- [ ] Page loads in <2 seconds

**Soft Ads**:
- [ ] Ads show for free tier users only
- [ ] Ads hidden for Premium/Pro users
- [ ] AdSense code loads correctly
- [ ] No console errors
- [ ] Ads labeled as "Advertisement"
- [ ] Frequency capping works (max 1 per page)

---

## 🎯 Next Phases (After Admin Dashboard + Ads)

**Phase 5: Virtual Try-On** (2-3 weeks)
- FASHN API integration
- Body detection
- Render outfit on model
- Pro tier exclusive (15 renders/month)

**Phase 6: Shopping Integration** (2-3 weeks)
- Affiliate links (Amazon, Nordstrom, ASOS)
- "Complete the look" product suggestions
- Revenue share: 4-8%

**Phase 7: Scale** (Ongoing)
- Content marketing (SEO blog posts)
- Influencer partnerships
- Referral program
- Mobile app (Turbo Native)

---

## 📌 Quick Reference

**How to test Premium features manually**:
```ruby
rails console
user = User.find_by(email: 'your@email.com')
user.update(subscription_tier: 'premium')  # or 'pro'
user.update(admin: true)  # for admin access
```

**How to check MRR**:
```ruby
Analytics::SubscriptionMetrics.new.mrr
```

**How to view ad revenue**:
```ruby
AdImpression.estimated_revenue_today
AdImpression.this_month.count  # impressions
```

---

**Status**: Ready to launch agents
**Next Action**: Distribute tasks to specialized agents in parallel
**Last Updated**: 2025-12-11
