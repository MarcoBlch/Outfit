# Admin Dashboard Product Specifications

**Document Version**: 1.0
**Date**: 2025-12-11
**Owner**: Product Management
**Status**: Ready for Implementation

---

## Executive Summary

This document defines the product requirements, KPIs, and strategic decisions for the Outfit Maker Admin Dashboard and Soft Ads features. The goal is to enable data-driven decision-making while balancing user experience with business objectives.

**Primary Objectives**:
1. Enable manual testing of Premium/Pro features without payment friction
2. Track key business metrics (MRR, churn, conversion, usage)
3. Generate $5-50/month passive revenue from free tier through non-intrusive ads
4. Establish foundation for future data-driven product decisions

**Success Criteria**:
- Admin dashboard accessible and functional within 1 week
- All KPIs displaying accurate data with <2s load time
- Ads generating $5+ monthly revenue within first 30 days
- Free tier churn remains below 8% post-ad launch

---

## 1. Key Performance Indicators (KPIs) & Targets

### 1.1 Revenue Metrics (Must-Have)

| Metric | Definition | Target (Month 3) | Target (Month 6) | Priority | Dashboard Section |
|--------|-----------|------------------|------------------|----------|-------------------|
| **MRR** | Monthly Recurring Revenue from paid subscriptions | $500 | $1,500 | CRITICAL | Overview |
| **ARPU** | Average Revenue Per User (paid users only) | $9.50 | $10.50 | HIGH | Subscriptions |
| **Ad Revenue** | Monthly revenue from AdSense (free tier) | $10 | $30 | MEDIUM | Overview |
| **Total Monthly Revenue** | MRR + Ad Revenue | $510 | $1,530 | CRITICAL | Overview |

**Calculation Logic**:
```ruby
# MRR Breakdown
MRR = (Premium_Users × $7.99) + (Pro_Users × $14.99)

# ARPU (excludes free tier)
ARPU = MRR / (Premium_Users + Pro_Users)

# Total Revenue
Total = MRR + Ad_Revenue_Monthly
```

**Why These Targets?**:
- Month 3 assumes 50 Premium + 10 Pro users = $549 MRR (achievable with 5% conversion from 1,200 free users)
- Month 6 assumes 150 Premium + 20 Pro users = $1,499 MRR (10% conversion from 2,000 free users)
- Ad revenue scales with free user base (500 free users × 20 pageviews/week × $2 CPM = $20/month)

---

### 1.2 Subscription Health Metrics (Must-Have)

| Metric | Definition | Target (Month 3) | Target (Month 6) | Priority | Alert Threshold |
|--------|-----------|------------------|------------------|----------|-----------------|
| **Conversion Rate (Free→Premium)** | % of free users who upgrade to Premium | 3% | 5% | CRITICAL | <2% = RED |
| **Conversion Rate (Premium→Pro)** | % of Premium users who upgrade to Pro | 8% | 12% | HIGH | <5% = YELLOW |
| **Monthly Churn Rate** | % of paid users who cancel each month | <8% | <6% | CRITICAL | >10% = RED |
| **Average Subscription Lifetime** | Days between signup and cancellation | 120 days | 180 days | HIGH | <90 days = YELLOW |
| **Reactivation Rate** | % of cancelled users who resubscribe | 5% | 10% | MEDIUM | N/A |

**Calculation Logic**:
```ruby
# Conversion Rate (Free → Premium)
conversion_rate = (new_premium_users_this_month / total_free_users_start_of_month) × 100

# Churn Rate
churn_rate = (cancelled_subscriptions_this_month / total_active_subscriptions_start_of_month) × 100

# Avg Subscription Lifetime (for churned users only)
avg_lifetime = sum(days_between_signup_and_cancel) / total_churned_users
```

**Why These Targets Matter**:
- **3% free→premium conversion** is standard for freemium SaaS (ranges 2-5%)
- **<8% churn** is healthy for consumer subscription apps (industry avg: 5-10%)
- **120+ day lifetime** ensures positive LTV:CAC ratio (customer profitable after ~4 months)

---

### 1.3 User Engagement Metrics (Must-Have)

| Metric | Definition | Target (Month 3) | Target (Month 6) | Priority | Alert Threshold |
|--------|-----------|------------------|------------------|----------|-----------------|
| **Daily Active Users (DAU)** | Users who log in + take action in past 24h | 150 | 300 | HIGH | <100 = YELLOW |
| **Weekly Active Users (WAU)** | Users who log in + take action in past 7 days | 500 | 1,000 | HIGH | <300 = YELLOW |
| **DAU/MAU Ratio** | Stickiness metric (daily engagement) | 15% | 20% | MEDIUM | <10% = YELLOW |
| **Avg Sessions per User per Week** | How often users return | 3 | 4 | MEDIUM | <2 = YELLOW |
| **Avg Outfit Suggestions per Active User** | Feature adoption (all tiers) | 2.5/week | 3.5/week | HIGH | <1.5 = YELLOW |

**Calculation Logic**:
```ruby
# DAU
dau = User.where("last_sign_in_at >= ?", 24.hours.ago).count

# DAU/MAU Ratio (stickiness)
stickiness = (dau / mau) × 100

# Avg Suggestions per Active User
avg_suggestions = OutfitSuggestion.this_week.count / User.active_this_week.count
```

**Why These Matter**:
- **15% stickiness** indicates users are forming habits (20%+ is excellent for consumer apps)
- **3+ sessions/week** shows product value beyond one-time use
- **2.5 suggestions/week** validates AI feature is core value prop

---

### 1.4 AI Usage & Cost Metrics (Must-Have)

| Metric | Definition | Target (Month 3) | Target (Month 6) | Priority | Alert Threshold |
|--------|-----------|------------------|------------------|----------|-----------------|
| **Total AI Suggestions/Day** | Gemini API calls per day | 100 | 250 | HIGH | N/A |
| **Estimated Monthly AI Cost** | Gemini API cost (assumes $0.01/call) | $30 | $75 | CRITICAL | >$100 = RED |
| **Cost per Paid User** | AI cost / paying users | $0.50 | $0.60 | HIGH | >$1.00 = YELLOW |
| **Avg API Response Time** | Gemini response latency (p50) | <3s | <2.5s | MEDIUM | >5s = YELLOW |
| **API Success Rate** | % of successful vs failed requests | >98% | >99% | HIGH | <95% = RED |

**Calculation Logic**:
```ruby
# Monthly AI Cost (conservative estimate)
monthly_cost = OutfitSuggestion.this_month.count × $0.01

# Cost per Paid User
cost_per_user = monthly_cost / (premium_users + pro_users)

# Success Rate
success_rate = (completed_suggestions / total_suggestions) × 100
```

**Why Cost Management Matters**:
- **$30-75/month AI cost** at 50-60 paid users = **$0.50-0.60 per paid user** (only 5-6% of ARPU)
- Target: Keep AI costs below 10% of revenue from paid users
- Red flag: If cost exceeds $100/month, need to optimize (caching, rate limiting adjustments)

---

### 1.5 Feature Adoption Metrics (Nice-to-Have)

| Metric | Definition | Target | Priority |
|--------|-----------|--------|----------|
| **Image Search Usage** | % of Premium+ users who use image search monthly | >40% | MEDIUM |
| **Profile Completion Rate** | % of users who complete 5-question profile | >70% | HIGH |
| **Wardrobe Item Upload Rate** | Avg items uploaded per user in first 7 days | 8+ | HIGH |
| **Outfit Creation Rate** | % of AI suggestions turned into saved outfits | >15% | MEDIUM |
| **"Why This Outfit?" Click Rate** | % of users who click rationale button | >50% | LOW |

**Why These Matter**:
- **40% image search adoption** validates Premium feature value (justifies $7.99 price)
- **70% profile completion** = better AI suggestions = higher retention
- **8+ items uploaded** in first week = users past "empty state" problem
- **15% suggestion→outfit conversion** = users see value, not just browsing

---

### 1.6 Ad Performance Metrics (Must-Have for Ads)

| Metric | Definition | Target | Priority | Alert Threshold |
|--------|-----------|--------|----------|-----------------|
| **Ad Impressions/Day (Free Tier)** | Daily ad views | 500 | HIGH | <200 = YELLOW |
| **Ad Click-Through Rate (CTR)** | % of impressions that result in clicks | 0.5-1.0% | MEDIUM | <0.3% = LOW QUALITY |
| **Ad Revenue per 1000 Free Users (RPM)** | Revenue per thousand free users | $40/month | HIGH | <$20 = UNDERPERFORMING |
| **Ad Complaints/Month** | User feedback about ads being intrusive | <5 | CRITICAL | >10 = REMOVE ADS |
| **Free Tier Churn (Post-Ads)** | Churn rate for free users after ads launch | <8% | CRITICAL | >10% = ADS HURTING UX |

**Calculation Logic**:
```ruby
# Ad RPM (Revenue per Mille = per 1000 users)
rpm = (monthly_ad_revenue / free_users) × 1000

# Example: $20/month ÷ 500 free users = $40 RPM
```

**Why These Targets**:
- **0.5-1.0% CTR** is industry standard for display ads
- **$40 RPM** assumes: 500 free users × 20 pageviews/week × 4 weeks × $2 CPM = $40/month per 1000 users
- **<5 complaints** indicates ads are non-intrusive (monitor via feedback link)

---

## 2. Dashboard UI Prioritization (v1 vs v2)

### 2.1 Version 1 (MVP - Ship Week 1)

**Goal**: Enable admin functionality and basic metrics tracking ASAP.

**Must-Have Features**:
1. **User Management**
   - User list (paginated, 50 per page)
   - Search by email
   - Filter by subscription tier (Free, Premium, Pro)
   - **Manual tier upgrade button** (critical for testing!)
   - View user details:
     - Email, signup date, subscription status
     - Wardrobe item count, outfit count
     - AI suggestion usage (today, this week, this month)
     - Last login date

2. **Overview Dashboard**
   - KPI Cards (6 total):
     - Total Users
     - Paying Users (count + %)
     - MRR
     - Monthly AI Cost
     - Free Tier Churn Rate
     - Avg Suggestions per User (this week)
   - Simple line chart: MRR over last 90 days
   - Simple pie chart: Users by tier (Free, Premium, Pro)

3. **Admin Authentication**
   - `admin` boolean flag on users table
   - Protect `/admin` routes with `before_action :require_admin!`
   - Manual console setup: `User.find_by(email: 'admin@example.com').update(admin: true)`

**Technology Stack**:
- Tailwind CSS (already in use)
- Heroicons for UI icons
- Chartkick gem for charts (simplest option)
- Turbo Frames for dynamic updates

**Rationale**: This MVP unblocks testing and provides visibility into core business metrics. Focus on speed over polish.

---

### 2.2 Version 2 (Enhanced - Ship Week 2-3)

**Goal**: Add advanced analytics and optimization features.

**Enhanced Features**:
1. **Advanced Filtering**
   - Filter users by activity level:
     - Active (logged in past 7 days)
     - Inactive (logged in 8-30 days ago)
     - Churned (no login 30+ days)
   - Filter by signup date range
   - Filter by feature usage (has image search, has profile completed, etc.)

2. **Cohort Analysis**
   - Retention table: % of users active after Day 1, 7, 30, 90
   - Grouped by signup week/month
   - Identify which cohorts have best retention

3. **Usage Analytics**
   - Peak usage times heatmap (hour of day × day of week)
   - Top 10 contexts for outfit suggestions (e.g., "date night", "job interview")
   - Feature funnel: Signup → Profile → Wardrobe Upload → First Suggestion → First Outfit
   - API performance: p50, p95, p99 response times

4. **Revenue Deep Dive**
   - Revenue by acquisition channel (if tracking implemented)
   - Lifetime Value (LTV) calculation by cohort
   - LTV:CAC ratio (if marketing spend tracked)
   - Subscription upgrade/downgrade flow visualization

5. **Ad Analytics Dashboard**
   - Ad impressions by placement (dashboard banner, wardrobe grid, etc.)
   - CTR by placement
   - Revenue by placement
   - A/B test results (if running placement experiments)

**Rationale**: These features enable strategic decisions but aren't blocking for launch. Ship v1 first, gather data, then build v2 based on actual needs.

---

### 2.3 Version 3 (Future Enhancements)

**Goal**: Automation and predictive analytics.

**Future Features** (ship after MVP validation):
- **Automated Alerts**: Email/Slack alerts when metrics hit thresholds (e.g., churn >10%, AI cost >$100)
- **Predictive Churn Model**: ML model to flag users at risk of cancelling
- **A/B Test Framework**: Built-in A/B testing for pricing, features, messaging
- **Customer Health Score**: Composite score based on engagement, usage, feedback
- **Automated Reports**: Weekly/monthly PDF reports emailed to stakeholders
- **User Segmentation**: Behavioral segments (power users, churned, at-risk, etc.)

**Rationale**: Don't build these until we validate v1 is useful and have data to inform v2. Classic product management: ship fast, learn, iterate.

---

## 3. Ad Placement Strategy

### 3.1 Ad Placement Options (Prioritized)

**Guiding Principles**:
1. Never show ads to Premium/Pro users
2. Label all ads transparently ("Advertisement" or "Sponsored")
3. Optimize for revenue without degrading user experience
4. Monitor free tier churn closely post-launch
5. Provide clear upgrade path ("Remove ads → Upgrade to Premium")

---

#### Option 1: Dashboard Banner (RECOMMENDED FOR v1)

**Placement**: Horizontal banner at top of dashboard, below navbar, above "Quick Actions"

**Specs**:
- Ad size: 728x90 (desktop), 320x50 (mobile) - responsive
- Frequency: 1 ad per dashboard page load
- Label: "Advertisement" in small gray text above banner
- Google AdSense auto-optimized banner ad

**Pros**:
- Highest visibility (users see dashboard frequently)
- Non-intrusive (doesn't interrupt workflow)
- Easy to implement (single partial in layout)
- Industry standard placement
- Predictable user experience

**Cons**:
- May feel "commercial" if too prominent
- Lower CTR than contextual placements

**Expected Performance**:
- 500 free users × 3 dashboard visits/week = 6,000 impressions/month
- CTR: 0.5% = 30 clicks/month
- $2 CPM = $12/month revenue

**Implementation**:
```erb
<!-- app/views/shared/_ad_banner.html.erb -->
<% unless current_user.premium? || current_user.pro? %>
  <div class="my-4 p-4 bg-gray-900/50 rounded-xl border border-white/10">
    <p class="text-xs text-gray-500 mb-2">Advertisement</p>
    <!-- Google AdSense responsive banner code -->
  </div>
<% end %>
```

**A/B Test Plan**: See Section 3.3 below.

---

#### Option 2: Wardrobe Grid Interstitial (v2 Enhancement)

**Placement**: Every 10th item in wardrobe grid (native ad style)

**Specs**:
- Ad looks like wardrobe item card (square format, 300x300)
- Label: "Sponsored" badge in top corner
- Frequency: Max 3 ads per page (limit to avoid spam feel)
- Google AdSense matched content or native ads

**Pros**:
- Less disruptive (blends with content)
- Higher engagement (users browsing wardrobe actively)
- Opportunity for fashion-specific affiliate products

**Cons**:
- More complex implementation (inject into grid)
- May feel misleading if not clearly labeled
- Interrupts browsing flow

**Expected Performance**:
- 500 free users × 10 wardrobe pageviews/week = 20,000 impressions/month
- CTR: 1.0% (higher due to context) = 200 clicks/month
- $2 CPM = $40/month revenue

**Implementation Priority**: v2 (after validating dashboard banner works)

---

#### Option 3: Post-Outfit Success Modal (v2 Enhancement)

**Placement**: After user saves outfit, show ad in success modal

**Specs**:
- Ad size: 300x250 medium rectangle
- Frequency: 1 ad per outfit saved (max 5/day per user)
- Label: "Advertisement - Complete the look"
- Closeable after 3 seconds (countdown timer)
- Google AdSense or fashion affiliate products

**Pros**:
- High engagement moment (user just completed action)
- "Complete the look" framing adds context
- Opportunity for relevant fashion products

**Cons**:
- May feel intrusive (interrupts success moment)
- Risk of user frustration if not closeable quickly
- Could hurt outfit creation rate if too annoying

**Expected Performance**:
- 500 free users × 2 outfits saved/week = 4,000 impressions/month
- CTR: 2.0% (high due to context) = 80 clicks/month
- $3 CPM (higher due to engagement) = $12/month revenue

**Implementation Priority**: v2 (requires careful UX testing)

---

### 3.2 Frequency Capping Rules

**Goal**: Maximize revenue while maintaining good user experience.

**Global Rules (All Placements)**:
- Never show ads to Premium/Pro users (hardcoded check)
- Max 10 ad impressions per user per day (prevent ad fatigue)
- Max 5 unique ad creatives per session (prevent repetition)
- No ads on signup/onboarding flow (critical conversion path)

**Per-Placement Rules**:

| Placement | Max Frequency | Logic |
|-----------|---------------|-------|
| Dashboard Banner | 1 per page load | Simple: render once per page |
| Wardrobe Grid | 1 per 10 items, max 3/page | Inject every 10th index, cap at 3 |
| Outfit Success Modal | 1 per outfit saved, max 5/day | Track count in session/cache |

**Implementation**:
```ruby
# app/helpers/ads_helper.rb
module AdsHelper
  def should_show_ads?
    return false if current_user.premium? || current_user.pro?

    # Check daily impression cap
    today = Date.current
    cache_key = "ad_impressions:#{current_user.id}:#{today}"
    impressions = Rails.cache.read(cache_key) || 0

    impressions < 10
  end

  def record_ad_impression!
    return unless should_show_ads?

    today = Date.current
    cache_key = "ad_impressions:#{current_user.id}:#{today}"
    current = Rails.cache.read(cache_key) || 0
    Rails.cache.write(cache_key, current + 1, expires_in: 24.hours)
  end
end
```

---

### 3.3 A/B Test Plan

**Goal**: Optimize ad placement for revenue without hurting free tier retention.

**Hypothesis**: Dashboard banner ads will generate $10+/month without increasing free tier churn above 8%.

**Test Structure**:

| Variant | Description | Users | Duration |
|---------|-------------|-------|----------|
| **Control** | No ads (current experience) | 50% of free users | 4 weeks |
| **Treatment** | Dashboard banner ads (Option 1) | 50% of free users | 4 weeks |

**Primary Metrics** (tracked daily):
1. Free tier churn rate (treatment vs control)
2. Ad revenue per user (treatment only)
3. Sessions per user per week (measure engagement drop)
4. Ad complaints via feedback link (treatment only)

**Secondary Metrics**:
1. Dashboard bounce rate (treatment vs control)
2. Upgrade rate (free → premium) - ads may motivate upgrades!
3. User satisfaction survey (send to 10% of each group post-test)

**Success Criteria**:
- **Ship Ads Permanently If**:
  - Ad revenue >$5/month AND
  - Free tier churn (treatment) < 9% (max 1% increase vs control) AND
  - <5 complaints per month

- **Iterate or Remove If**:
  - Free tier churn (treatment) > 10% (2%+ increase = red flag)
  - Ad revenue < $5/month (not worth the risk)
  - >10 complaints per month (users hate it)

**Implementation**:
```ruby
# Use simple cookie-based assignment
def ad_test_variant
  return :control if current_user.premium? || current_user.pro?

  # Assign based on user ID (consistent assignment)
  current_user.id.even? ? :treatment : :control
end
```

**Data Collection**:
- Log ad impressions to `ad_impressions` table (user_id, placement, clicked, timestamp)
- Track churn events in Stripe webhooks
- Weekly dashboard review to monitor trends

---

### 3.4 Upgrade Messaging Strategy

**Goal**: Convert ad annoyance into upgrade motivation.

**Messaging Locations**:

1. **Below Ad Banner**:
   ```
   [Ad Banner]

   Want an ad-free experience? Upgrade to Premium ($7.99/mo)
   ```

2. **After 3rd Ad Impression (Session)**:
   - Show modal: "Enjoying Outfit Maker? Upgrade to Premium for an ad-free experience + 30 AI suggestions/day"
   - Closeable, only once per session

3. **Feedback Link**:
   - Below each ad: "Ads too intrusive? Tell us or upgrade to Premium"
   - Tracks complaints (alert if >10/month)

**A/B Test on Messaging**:
- Variant A: "Remove ads → Upgrade to Premium" (fear-based)
- Variant B: "Unlock 30 AI suggestions/day + no ads → Upgrade to Premium" (value-based)
- Hypothesis: Variant B converts better (emphasizes value, not just ad removal)

---

## 4. Feature Prioritization Matrix

### 4.1 Prioritization Framework

**Evaluation Criteria** (weighted scoring):
1. **User Value** (30%): Does this solve a real user problem?
2. **Business Impact** (30%): Does this drive revenue, retention, or cost savings?
3. **Technical Feasibility** (20%): How complex is implementation?
4. **Strategic Alignment** (20%): Does this align with long-term vision?

**Scoring**: 1-5 scale (5 = highest)

---

### 4.2 Admin Dashboard Features (v1 vs v2)

| Feature | User Value | Business Impact | Tech Feasibility | Strategic Alignment | **Total Score** | **Version** |
|---------|------------|-----------------|------------------|---------------------|-----------------|-------------|
| User list with search | 3 | 5 | 5 | 5 | **4.4** | v1 |
| Manual tier upgrade button | 5 | 5 | 5 | 5 | **5.0** | v1 |
| MRR calculation | 2 | 5 | 5 | 5 | **4.2** | v1 |
| User detail page | 4 | 4 | 5 | 4 | **4.2** | v1 |
| Subscription metrics dashboard | 3 | 5 | 4 | 5 | **4.2** | v1 |
| AI cost tracking | 3 | 5 | 4 | 4 | **4.0** | v1 |
| Basic charts (MRR, users by tier) | 3 | 4 | 5 | 4 | **3.9** | v1 |
| **Cohort retention analysis** | 4 | 4 | 3 | 5 | **4.0** | **v2** |
| **Peak usage heatmap** | 2 | 3 | 3 | 3 | **2.7** | **v2** |
| **Top contexts analysis** | 3 | 3 | 5 | 3 | **3.4** | **v2** |
| **Revenue by channel** | 3 | 4 | 2 | 4 | **3.3** | **v2** |
| **Automated alerts** | 4 | 3 | 3 | 4 | **3.5** | **v3** |
| **Predictive churn model** | 5 | 5 | 1 | 4 | **3.8** | **v3** |

**Key Decisions**:
- **Ship v1 in Week 1**: Focus on must-haves (score 4.0+) that enable testing and basic tracking
- **Ship v2 in Week 2-3**: Add nice-to-haves (score 3.5-4.0) after validating v1 usefulness
- **Defer v3**: Don't build automation until we have data to inform it (YAGNI principle)

---

### 4.3 Ad Features (v1 vs v2)

| Feature | User Value | Business Impact | Tech Feasibility | Strategic Alignment | **Total Score** | **Version** |
|---------|------------|-----------------|------------------|---------------------|-----------------|-------------|
| Dashboard banner ads | 2 | 4 | 5 | 4 | **3.7** | v1 |
| AdSense integration | 2 | 5 | 5 | 5 | **4.2** | v1 |
| Frequency capping (10/day) | 4 | 3 | 4 | 4 | **3.7** | v1 |
| Transparent ad labeling | 5 | 2 | 5 | 5 | **4.1** | v1 |
| Ad impression tracking | 2 | 4 | 4 | 4 | **3.5** | v1 |
| **Wardrobe grid native ads** | 3 | 4 | 3 | 4 | **3.5** | **v2** |
| **Outfit success modal ads** | 2 | 4 | 3 | 3 | **3.0** | **v2** |
| **A/B test framework** | 3 | 5 | 4 | 5 | **4.2** | **v2** |
| **Affiliate product integration** | 4 | 5 | 2 | 5 | **4.0** | **v3** |

**Key Decisions**:
- **Start Simple (v1)**: Dashboard banner only with AdSense (easiest, proven model)
- **A/B Test First**: Validate revenue/churn hypothesis before adding more placements
- **v2 = Multiple Placements**: Only ship wardrobe grid and modal ads if dashboard ads succeed
- **v3 = Affiliate Links**: Higher effort, ship only after ads validated as revenue driver

---

## 5. Testing & Validation Checklist

### 5.1 Admin Dashboard Testing (Pre-Launch)

**Functional Testing**:

- [ ] **Authentication**
  - [ ] Non-admin user redirected from `/admin` with error message
  - [ ] Admin user can access `/admin` dashboard
  - [ ] Admin flag persists across sessions
  - [ ] Admin can log out and back in successfully

- [ ] **User Management**
  - [ ] User list displays all users paginated (50 per page)
  - [ ] Search by email returns correct results (partial match)
  - [ ] Filter by tier (Free, Premium, Pro) works correctly
  - [ ] Manual tier upgrade button changes `subscription_tier` in database
  - [ ] User detail page shows accurate stats (wardrobe count, outfit count, AI usage)
  - [ ] Last login date updates correctly

- [ ] **Metrics Accuracy**
  - [ ] MRR calculation matches Stripe dashboard (cross-check)
  - [ ] ARPU calculation excludes free users
  - [ ] User count by tier matches database queries
  - [ ] AI cost calculation matches `OutfitSuggestion.this_month.sum(:api_cost)`
  - [ ] Churn rate calculation uses correct formula (see KPI section)

- [ ] **Performance**
  - [ ] Dashboard loads in <2 seconds (including charts)
  - [ ] User list pagination loads <1 second per page
  - [ ] Charts render without blocking page load (async)
  - [ ] No N+1 queries (check logs with Bullet gem)

**Edge Cases**:

- [ ] User with 0 wardrobe items displays correctly (no division by zero)
- [ ] User with 0 AI suggestions shows "No activity yet"
- [ ] Newly signed up user (today) shows in user list immediately
- [ ] Cancelled subscription displays correct "Cancelled" status
- [ ] Past due subscription displays warning indicator

**Browser Compatibility**:
- [ ] Chrome (latest)
- [ ] Safari (latest)
- [ ] Firefox (latest)
- [ ] Mobile Safari (iOS)

---

### 5.2 Soft Ads Testing (Pre-Launch)

**Functional Testing**:

- [ ] **Ad Display Logic**
  - [ ] Ads show for free tier users only
  - [ ] Ads hidden for Premium users
  - [ ] Ads hidden for Pro users
  - [ ] Ad labeled as "Advertisement" clearly visible
  - [ ] AdSense code loads without JavaScript errors

- [ ] **Frequency Capping**
  - [ ] Dashboard banner appears once per page load
  - [ ] User sees max 10 ads per day (test with console cache check)
  - [ ] Counter resets at midnight UTC

- [ ] **Upgrade Messaging**
  - [ ] "Upgrade to Premium" link below ad works
  - [ ] Feedback link ("Ads too intrusive?") opens form/email
  - [ ] Modal appears after 3rd ad impression (once per session)

- [ ] **Ad Performance Tracking**
  - [ ] Ad impression recorded in `ad_impressions` table
  - [ ] Click tracked if user clicks ad (via Google Analytics)
  - [ ] Daily impression count accurate in admin dashboard

**A/B Test Validation**:

- [ ] Control group (50% of free users) sees no ads
- [ ] Treatment group (50% of free users) sees dashboard banner
- [ ] User assignment consistent across sessions (same user always in same group)
- [ ] Admin dashboard shows separate metrics for control vs treatment

**Edge Cases**:

- [ ] User upgrades to Premium mid-session → ads disappear on next page load
- [ ] User downgrades from Premium to Free → ads appear on next login
- [ ] AdSense account suspended → fallback message displays ("Ad loading...")
- [ ] User has ad blocker → no console errors, no broken layout

---

### 5.3 User Acceptance Criteria (UAC)

**Admin Dashboard UAC**:

**As an Admin, I want to**:
1. **Manually upgrade a user to Premium/Pro** so I can test features without payment
   - **Acceptance**: Click "Upgrade to Premium" on user detail page → user's `subscription_tier` updates to `premium` → user sees Premium features immediately on next login

2. **See accurate MRR calculation** so I can track business performance
   - **Acceptance**: MRR on dashboard matches `(Premium_Users × $7.99) + (Pro_Users × $14.99)` ± $0.01

3. **Identify users at risk of churn** so I can reach out proactively
   - **Acceptance**: User list filterable by "Last login >30 days ago" → shows only inactive users

4. **Monitor AI API costs** so I can prevent runaway expenses
   - **Acceptance**: Dashboard shows "Monthly AI Cost" card → matches `OutfitSuggestion.this_month.sum(:api_cost)` → red alert if >$100

**Soft Ads UAC**:

**As a Free Tier User, I want to**:
1. **See ads that are clearly labeled** so I know what's an ad vs app content
   - **Acceptance**: "Advertisement" label appears above/below ad in gray text

2. **Not be overwhelmed by ads** so my experience isn't degraded
   - **Acceptance**: I see max 1 ad per page, max 10 ads per day

3. **Have an option to remove ads** so I can upgrade if ads bother me
   - **Acceptance**: "Upgrade to Premium" link visible below ad → clicks through to pricing page

**As a Premium/Pro User, I want to**:
1. **Never see ads** so my paid experience is ad-free
   - **Acceptance**: No ads visible on any page after logging in as Premium/Pro user

---

### 5.4 Monitoring & Alerts (Post-Launch)

**Daily Checks** (Week 1-2 post-launch):
- [ ] Check MRR vs yesterday (any unexpected drops?)
- [ ] Check churn events (any mass cancellations?)
- [ ] Check AI API cost (approaching $100 limit?)
- [ ] Check ad revenue (AdSense dashboard)
- [ ] Check user complaints (inbox, feedback form)

**Weekly Checks** (Ongoing):
- [ ] Review A/B test results (control vs treatment churn)
- [ ] Review ad CTR (any placements underperforming?)
- [ ] Review conversion funnel (signup → profile → first suggestion → upgrade)
- [ ] Review top feature requests (prioritize roadmap)

**Automated Alerts** (if implemented in v2):
- [ ] Email alert if churn rate >10% (check daily)
- [ ] Email alert if AI cost >$100/month (check weekly)
- [ ] Email alert if ad revenue <$5/month for 2 weeks (underperforming)
- [ ] Email alert if ad complaints >10/month (UX issue)

---

## 6. Risk Mitigation

### 6.1 Business Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|---------------------|
| **Free tier churn increases >10% due to ads** | MEDIUM | HIGH | A/B test first; monitor daily; remove ads if churn spikes; improve ad quality/placement |
| **Ad revenue <$5/month (not worth it)** | MEDIUM | LOW | Track for 60 days; if underperforming, remove ads and focus on paid conversions instead |
| **AI API costs exceed $100/month** | LOW | MEDIUM | Set up alerts; implement aggressive caching; reduce free tier rate limits (3→2/day) |
| **Stripe webhook issues cause subscription mismatches** | LOW | HIGH | Log all webhook events; add manual sync button in admin; monitor daily |
| **Users abuse manual tier upgrade for free Premium** | LOW | LOW | Only accessible to admins; track upgrade source in database; periodic audits |

---

### 6.2 Technical Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|---------------------|
| **N+1 queries slow down admin dashboard** | MEDIUM | MEDIUM | Use `includes` for associations; add database indexes; test with production-scale data |
| **AdSense account rejected/suspended** | LOW | MEDIUM | Have backup (direct ad sales, affiliate links); apply for AdSense early; follow policies |
| **Charts fail to render on mobile** | LOW | LOW | Test on iOS/Android; use responsive Chartkick settings; fallback to tables if needed |
| **Redis cache issues cause incorrect rate limiting** | LOW | HIGH | Fallback to database-backed counters; monitor Redis uptime; test cache expiry logic |
| **Frequency capping bypassed by clearing cookies** | MEDIUM | LOW | Accept this risk (not worth complex solutions like fingerprinting) |

---

### 6.3 UX Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|-----------|--------|---------------------|
| **Ads feel too intrusive, hurt brand perception** | MEDIUM | HIGH | A/B test first; use transparent labeling; limit frequency; provide clear upgrade path |
| **Users confused by manual tier upgrade (think they'll be charged)** | LOW | LOW | Add warning message: "This is a manual upgrade for testing. No Stripe charge." |
| **Admin dashboard too complex, not used** | LOW | MEDIUM | Start with MVP (v1); gather feedback from actual usage; iterate based on needs |
| **Users complain ads aren't relevant (fashion vs random)** | MEDIUM | LOW | Work with AdSense to optimize ad categories; consider fashion-specific ad networks later |

---

## 7. Success Metrics & Launch Readiness

### 7.1 Launch Criteria (Admin Dashboard)

**Must be TRUE before shipping to production**:
- [ ] All v1 features implemented and tested
- [ ] Admin authentication working (only admin can access)
- [ ] MRR calculation accurate (cross-checked with Stripe)
- [ ] Manual tier upgrade tested on staging
- [ ] Dashboard loads in <2 seconds
- [ ] No critical bugs (P0/P1)
- [ ] Database migrations run successfully
- [ ] Indexes added for performance

**Nice-to-Have (can ship without)**:
- [ ] Charts fully styled/polished
- [ ] Mobile responsive (admin dashboard is desktop-first)
- [ ] User activity timeline (v2 feature)

---

### 7.2 Launch Criteria (Soft Ads)

**Must be TRUE before shipping to production**:
- [ ] AdSense account approved and active
- [ ] Ads display correctly for free tier only
- [ ] Frequency capping tested and working
- [ ] Transparent labeling ("Advertisement") visible
- [ ] No JavaScript errors in console
- [ ] Upgrade messaging displays correctly
- [ ] A/B test assignment logic working
- [ ] Ad impression tracking functional

**Nice-to-Have (can ship without)**:
- [ ] Multiple ad placements (v2 = wardrobe grid, modal)
- [ ] Affiliate links (v3)
- [ ] Advanced ad targeting

---

### 7.3 Post-Launch Success Metrics (30-Day Checkpoint)

**Admin Dashboard**:
- [ ] Used by admin at least 5x/week (proves value)
- [ ] Manual tier upgrade used at least 10 times (testing enabled)
- [ ] No critical bugs reported
- [ ] Dashboard load time <2 seconds maintained

**Soft Ads**:
- [ ] Ad revenue >$5/month (minimum viable revenue)
- [ ] Free tier churn <9% (no significant increase vs pre-ads)
- [ ] <5 complaints about ads (good UX)
- [ ] A/B test completed with statistical significance

**Decision Point (Day 30)**:
- **If ads successful**: Ship v2 (additional placements), iterate on optimization
- **If ads underperforming but not harmful**: Continue for 60 days, optimize placement/messaging
- **If ads hurting UX (churn >10%)**: Remove ads, focus 100% on paid conversion optimization

---

## 8. Implementation Timeline

### Week 1: Admin Dashboard (MVP)
- **Day 1-2**: Backend (admin auth, controllers, analytics services)
- **Day 3-4**: Frontend (dashboard UI, user management)
- **Day 5**: Database (migrations, indexes)
- **Day 6-7**: Integration testing + staging deployment

### Week 2: Soft Ads + A/B Test
- **Day 1-2**: AdSense signup + integration (dashboard banner)
- **Day 3**: Frequency capping + tracking implementation
- **Day 4**: A/B test setup (control vs treatment split)
- **Day 5-7**: Testing + production deployment

### Week 3-4: Monitoring + Iteration
- **Daily**: Monitor A/B test metrics (churn, revenue, complaints)
- **Weekly**: Review admin dashboard usage, identify pain points
- **End of Week 4**: Decide on ads (keep, optimize, or remove)

### Week 5+: v2 Features (If Applicable)
- Cohort analysis
- Additional ad placements (if v1 successful)
- Advanced filtering
- Automated alerts

---

## 9. Open Questions & Decisions Needed

### 9.1 Product Decisions
- [ ] **AdSense Category Restrictions**: Should we restrict ad categories (e.g., no gambling, dating apps)? → **Recommendation**: Yes, use AdSense blocking controls for brand safety
- [ ] **Free Tier Rate Limit Adjustment**: If AI costs too high, reduce from 3→2 suggestions/day? → **Recommendation**: Monitor first 30 days, then decide
- [ ] **Manual Tier Upgrade Tracking**: Should we flag manually upgraded users in database? → **Recommendation**: Yes, add `upgrade_source` field (values: "stripe", "manual_admin")

### 9.2 Technical Decisions
- [ ] **Chart Library**: Chartkick (simple) vs Chart.js (flexible)? → **Recommendation**: Chartkick for v1 MVP (faster), migrate to Chart.js if customization needed
- [ ] **Cache Strategy**: Redis (current) vs database-backed for rate limiting? → **Recommendation**: Keep Redis, add database fallback for reliability
- [ ] **Ad Impression Storage**: Store in database vs just Google Analytics? → **Recommendation**: Store in database (enables cohort analysis, A/B testing)

### 9.3 Design Decisions
- [ ] **Admin Dashboard Branding**: Should admin panel have different color scheme vs main app? → **Recommendation**: Yes, use purple accent (vs pink for main app) to differentiate
- [ ] **Ad Styling**: Match app dark theme vs standard light ad units? → **Recommendation**: Use AdSense auto-styling (better fill rate), but request dark-compatible ads

---

## 10. Appendix

### 10.1 Benchmark Data (Industry Standards)

**SaaS Freemium Conversion Rates**:
- **Free → Paid**: 2-5% (median: 3%)
- **Source**: OpenView Partners 2024 SaaS Benchmarks

**Consumer Subscription Churn**:
- **Monthly Churn**: 5-10% (median: 7%)
- **Source**: Recurly 2024 Subscription Benchmarks

**Ad Performance (Fashion/Lifestyle)**:
- **CPM**: $1-3 (median: $2)
- **CTR**: 0.3-1.0% (median: 0.5%)
- **Source**: Google AdSense Fashion Category Benchmarks

**SaaS Engagement (DAU/MAU)**:
- **Consumer Apps**: 10-20% (median: 15%)
- **Productivity Apps**: 20-40% (median: 30%)
- **Source**: Mixpanel Engagement Benchmarks 2024

---

### 10.2 Competitive Analysis (Ad Strategies)

**Spotify Free Tier**:
- Audio ads every 15 minutes
- Banner ads on mobile app
- Upgrade messaging: "Go Premium for ad-free"
- **Learning**: Clear upgrade path increases conversion

**Canva Free Tier**:
- No ads! Monetizes via limited features
- Upgrade messaging throughout app
- **Learning**: Some freemium apps succeed without ads (focus on feature differentiation)

**Pinterest Free Tier**:
- Native "Promoted Pin" ads (blend with content)
- No banner ads
- **Learning**: Native ads feel less intrusive, higher engagement

**Recommendation for Outfit Maker**: Start with banner ads (Option 1) like Spotify, but move toward native ads (Option 2) if user feedback suggests it's too commercial.

---

### 10.3 Contact & Escalation

**Product Owner**: Product Manager (this role)
**Technical Lead**: Backend/Frontend Agents (delegated implementation)
**Stakeholder Approval Required For**:
- Changing pricing ($7.99, $14.99)
- Removing ads if launched
- Major pivots (e.g., dropping freemium model)

**Escalation Criteria**:
- Churn >10% for 2 consecutive weeks
- AI costs >$150/month
- Security breach in admin panel
- Legal complaint about ads (copyright, inappropriate content)

---

## Document Changelog

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-12-11 | Initial release | Product Manager |

---

**Next Steps**:
1. Review this document with technical leads
2. Confirm v1 scope alignment
3. Distribute tasks to agents (Backend, Frontend, Database)
4. Begin Week 1 implementation (Admin Dashboard MVP)
5. Apply for Google AdSense account (can take 3-7 days)

**Questions?** Open an issue or contact Product Manager.
