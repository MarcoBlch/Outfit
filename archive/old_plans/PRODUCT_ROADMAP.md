# Outfit Maker: Complete Product & Monetization Roadmap

## Executive Summary

**Vision**: AI-powered fashion assistant that helps users create outfits from their existing wardrobe with context-aware recommendations, virtual try-on, and shopping suggestions.

**Tech Stack**: Rails 7 + Hotwire (Turbo/Stimulus) + Tailwind CSS v4 + Vertex AI (Gemini 2.5)

**Business Model**: 3-tier SaaS (Free / Premium $7.99/mo / Pro $14.99/mo) + Affiliate Revenue

**Target**: $10k MRR by Week 41 (8 months post-monetization)

---

## Phase 1: Foundation & Core Value (Weeks 1-4) - FREE TIER ONLY

### Goal
Prove core value proposition: "AI stylist that actually knows your closet"

### Features

#### 1.1 Context-Based Outfit Recommendations ⭐ KILLER FEATURE
**Priority**: HIGHEST - Ship this FIRST

**User Story**:
"I have a job interview at a tech startup tomorrow. What should I wear from my wardrobe?"

**Technical Implementation**:
```ruby
# app/services/outfit_suggestion_service.rb
class OutfitSuggestionService
  def initialize(user, context, weather: nil)
    @user = user
    @context = context
    @weather = weather
    @gemini = ImageAnalysisService.new
  end

  def generate_suggestions(count: 3)
    # 1. Build context-aware prompt with wardrobe inventory
    # 2. Call Gemini API (already integrated!)
    # 3. Parse JSON response with outfit combinations
    # 4. Validate item IDs exist in user's wardrobe
    # 5. Return ranked suggestions with reasoning
  end
end
```

**Endpoints**:
- `POST /outfits/suggest` - Generate AI suggestions
- `GET /outfits/suggestions/:id` - View specific suggestion
- `POST /outfits/suggestions/:id/save` - Save suggestion as outfit

**UI Components**:
- Dashboard: Prominent "Get Outfit Suggestions" CTA
- Context input: Text area ("job interview", "date night", "casual Friday")
- Results: 3 cards showing outfit combinations with reasoning
- Canvas preview: Click suggestion → auto-populate outfit canvas

**Free Tier Limits**:
- 3 AI suggestions per day
- Basic context (occasion only, no weather)

**Timeline**: 2-3 weeks

---

#### 1.2 Wardrobe Upload Improvements
**Enhancement to existing feature**

**Changes**:
- Batch upload (select multiple images at once)
- Progress indicator for multi-image upload
- "Upload 10 items to unlock AI stylist" onboarding nudge
- Improved auto-tagging with Gemini 2.5

**Timeline**: 3-5 days

---

#### 1.3 Analytics & Instrumentation
**Critical for future phases**

**Metrics to Track**:
- Sign-ups per day/week
- Wardrobe items uploaded (avg per user)
- AI suggestions requested (total & per user)
- Outfit canvas usage
- Retention: Day 1, 7, 30

**Tools**:
- Mixpanel or Plausible Analytics
- Custom Rails events (`Ahoy` gem)

**Timeline**: 2-3 days

---

### Success Criteria (Before Moving to Phase 2)
- ✅ 200+ active users (weekly active)
- ✅ 60%+ users upload 10+ wardrobe items
- ✅ 50%+ Week 1 → Week 4 retention
- ✅ Average 5+ AI suggestions used per engaged user per week
- ✅ Net Promoter Score (NPS) > 40

**IF SUCCESS CRITERIA NOT MET**: Iterate on Phase 1, don't move forward.

---

## Phase 2: Personalization (Weeks 5-8) - STILL FREE ONLY

### Goal
Enhance AI recommendations with user profiles and weather context

### Features

#### 2.1 User Profile System
**Implementation**:
```ruby
# app/models/user_profile.rb
class UserProfile < ApplicationRecord
  belongs_to :user

  enum style_preference: {
    casual: 0,
    business_casual: 1,
    formal: 2,
    streetwear: 3,
    minimalist: 4,
    bohemian: 5,
    eclectic: 7
  }

  enum body_type: {
    slim: 0,
    athletic: 1,
    average: 2,
    curvy: 3,
    plus_size: 4
  }

  validates :age_range, inclusion: {
    in: %w[18-24 25-34 35-44 45-54 55+]
  }
end
```

**UI Flow**:
- Simple 5-question onboarding form
- Optional (skippable), but incentivized: "Get better recommendations by completing your profile"
- Fields: Age range, style preference, body type, favorite colors (multi-select), location (for weather)

**Timeline**: 1 week

---

#### 2.2 Weather Integration
**Implementation**:
```ruby
# Gemfile
gem 'openweathermap'

# app/services/weather_service.rb
class WeatherService
  def initialize(location)
    @location = location
    @api = OpenWeatherMap::Current.city(location, ENV['OPENWEATHER_API_KEY'])
  end

  def current_conditions
    {
      temp: @api.temperature,
      condition: @api.weather.description,
      feels_like: @api.feels_like
    }
  end
end
```

**Enhancement to OutfitSuggestionService**:
- Include weather context in Gemini prompt
- "It's 45°F and rainy today. Here are weather-appropriate outfits..."

**Free Tier**: Basic weather (temp + condition)

**Timeline**: 3-4 days

---

#### 2.3 PWA Support
**Progressive Web App for mobile experience**

**Implementation**:
```javascript
// app/javascript/manifest.json
{
  "name": "Outfit Maker",
  "short_name": "Outfits",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#your-brand-color",
  "background_color": "#ffffff",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

**Features**:
- Add to home screen
- Offline fallback page
- Push notifications (opt-in): "Your outfit for today"

**Timeline**: 2-3 days

---

#### 2.4 Outfit Export & Sharing
**User Story**: "I want to share this outfit on Instagram"

**Features**:
- Export outfit as high-quality image (outfit canvas screenshot)
- Include watermark: "Created with Outfit Maker" (brand awareness)
- Share link (public outfit view)
- Social meta tags for preview on Twitter/Instagram

**Free Tier**: Low-res export with watermark

**Timeline**: 3-4 days

---

### Success Criteria (Before Phase 3)
- ✅ 70%+ users complete profile
- ✅ Weather integration increases suggestion usage by 20%+
- ✅ 500+ total users
- ✅ 10+ shared outfits generating organic traffic
- ✅ Day 7 retention: 50%+

---

## Phase 3: Discovery & Monetization Launch (Weeks 9-12)

### Goal
Add image-based discovery features AND introduce Premium tier

### Features

#### 3.1 Image-Based Search
**User Story**: "I saw this outfit on Instagram. Do I have similar items in my wardrobe?"

**Implementation**:
```ruby
# app/services/wardrobe_search_service.rb
class WardrobeSearchService
  def initialize(user)
    @user = user
  end

  def find_similar_items(inspiration_image_path, limit: 5)
    # 1. Generate embedding for inspiration image using Vertex AI
    embedding = EmbeddingService.new.embed_image(inspiration_image_path)

    # 2. Vector similarity search using pgvector
    WardrobeItem
      .where(user: @user)
      .nearest_neighbors(:embedding, embedding, distance: "cosine")
      .limit(limit)
  end

  def suggest_outfit_from_inspiration(inspiration_image_path)
    # 1. Find similar items in wardrobe
    # 2. Use Gemini to analyze inspiration outfit
    # 3. Suggest combination from user's wardrobe that matches style
  end
end
```

**UI**:
- Upload inspiration image (drag-and-drop or URL)
- Show similar items from wardrobe (visual grid)
- "Create similar outfit" button → auto-populate canvas

**Free Tier**: Not available (Premium feature)
**Premium Tier**: 5 searches per day

**Timeline**: 1.5-2 weeks

---

#### 3.2 Outfit of the Day (OOTD) Automation
**User Story**: "Show me what to wear today based on my schedule and weather"

**Implementation**:
```ruby
# app/jobs/daily_outfit_suggestion_job.rb
class DailyOutfitSuggestionJob < ApplicationJob
  queue_as :default

  def perform
    User.with_active_subscriptions.find_each do |user|
      # 1. Check calendar events (if integrated)
      # 2. Get weather for user's location
      # 3. Generate outfit suggestion
      # 4. Send push notification / email
      # 5. Pre-render on dashboard
    end
  end
end

# Schedule: Daily at 6am user's local time
```

**Free Tier**: Not available
**Premium Tier**: Daily OOTD on dashboard + optional push notification

**Timeline**: 1 week

---

#### 3.3 **PREMIUM TIER LAUNCH** 💰

**Pricing**:
- $7.99/month
- $79/year (save 17% - $6.58/month)

**Features Included**:
- Up to 300 wardrobe items (vs. 50 free)
- 30 AI suggestions per day (vs. 3 free)
- Auto-tagging with AI (vs. manual free)
- Full weather integration (vs. basic free)
- Image-based search (5/day)
- Outfit of the Day automation
- High-res exports (vs. low-res watermarked free)
- Email support (48-hour response)

**Technical Implementation**:
```ruby
# Gemfile
gem 'stripe'

# app/models/subscription.rb
class Subscription < ApplicationRecord
  belongs_to :user

  enum tier: { free: 0, premium: 1, pro: 2 }
  enum status: { active: 0, canceled: 1, past_due: 2 }

  def self.check_limits(user, feature)
    case user.subscription.tier
    when 'free'
      LIMITS[:free][feature]
    when 'premium'
      LIMITS[:premium][feature]
    when 'pro'
      LIMITS[:pro][feature]
    end
  end
end

# config/initializers/stripe.rb
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

LIMITS = {
  free: {
    wardrobe_items: 50,
    ai_suggestions_per_day: 3,
    image_searches_per_day: 0,
    auto_tagging: false
  },
  premium: {
    wardrobe_items: 300,
    ai_suggestions_per_day: 30,
    image_searches_per_day: 5,
    auto_tagging: true
  },
  pro: {
    wardrobe_items: Float::INFINITY,
    ai_suggestions_per_day: 100, # soft limit, monitoring
    image_searches_per_day: Float::INFINITY,
    auto_tagging: true,
    virtual_tryon_per_month: 15
  }
}
```

**Launch Strategy**:
- Email all users: "Introducing Premium - Founding Member Discount"
- First 500 paying users: Lifetime 30% off ($5.59/month)
- 14-day free trial (requires credit card)
- Prominent upgrade prompts when hitting free tier limits

**Timeline**: 1 week for Stripe integration + pricing page

---

### Success Criteria (Before Phase 4)
- ✅ 50+ paying Premium customers by end of week 12
- ✅ 4-6% free → premium conversion rate
- ✅ $400-500 MRR
- ✅ <10% monthly churn
- ✅ 1,000+ total users (free + paid)

---

## Phase 4: Virtual Try-On & Pro Tier (Weeks 13-16)

### Goal
Add premium visual feature (virtual try-on) and introduce Pro tier

### Features

#### 4.1 FASHN API Integration - Virtual Try-On

**User Story**: "I want to see how this outfit looks on a model before I commit to wearing it"

**Technical Implementation**:
```ruby
# Gemfile
gem 'httparty'

# app/services/virtual_tryon_service.rb
class VirtualTryonService
  FASHN_API_ENDPOINT = "https://api.fashn.ai/v1/run"

  def initialize(user)
    @user = user
    @api_key = ENV['FASHN_API_KEY']
  end

  def generate_tryon(outfit_id, model_preference: 'auto')
    outfit = Outfit.find(outfit_id)

    # 1. Check user's Pro tier limits (15 renders/month)
    return { error: "Monthly limit reached" } unless within_limits?

    # 2. Prepare request to FASHN API
    # - Model image (from user upload or stock model)
    # - Garment images (from outfit's wardrobe items)

    # 3. Make API request
    response = HTTParty.post(
      FASHN_API_ENDPOINT,
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      },
      body: {
        model_image: model_image_url,
        garment_image: garment_image_url,
        category: 'tops' # or 'bottoms', 'full', 'dresses'
      }.to_json
    )

    # 4. Store result and track usage
    VirtualTryonRender.create!(
      user: @user,
      outfit: outfit,
      result_url: response['output_url'],
      cost: 0.06 # Track actual cost
    )

    response
  end

  private

  def within_limits?
    @user.virtual_tryon_renders
         .where('created_at >= ?', 1.month.ago)
         .count < 15
  end
end
```

**UI Flow**:
1. User creates outfit on canvas
2. "Try On" button appears (Pro tier only)
3. Model selection: Upload photo OR use stock model
4. Processing: 5-17 seconds (show progress bar)
5. Result: High-quality rendered image
6. Options: Save, share, download

**Pro Tier Only**: 15 renders per month
**Cost**: $0.04-0.075 per render (volume pricing from FASHN)
**Pro Price**: $14.99/month (margin: $14.99 - $1.13 avg cost = $13.86)

**Timeline**: 1.5-2 weeks

---

#### 4.2 **PRO TIER LAUNCH** 💎

**Pricing**:
- $14.99/month
- $149/year (save 17% - $12.42/month)

**Features Included** (Everything in Premium PLUS):
- Unlimited wardrobe items
- Unlimited AI suggestions (soft limit 100/day with monitoring)
- Unlimited image searches
- **15 virtual try-on renders per month**
- Full wardrobe analytics & insights
- White-label sharing (remove "Created with Outfit Maker" watermark)
- Priority email support (12-hour response)

**Launch Strategy**:
- Premium users get 2-week exclusive early access
- Partner with 2-3 fashion micro-influencers (10k-50k followers)
- "See before you style" campaign
- Offer: First 100 Pro users get $11.99/month lifetime pricing

**Timeline**: 1 week after virtual try-on feature is stable

---

### Success Criteria (Before Phase 5)
- ✅ 10-20% of Premium users upgrade to Pro
- ✅ $1,000-1,500 MRR ($800 Premium + $200-700 Pro)
- ✅ Virtual try-on feature works reliably (>95% success rate)
- ✅ FASHN API costs stay under $2/Pro user/month
- ✅ 2,000+ total users

---

## Phase 5: Shopping Integration & Revenue Optimization (Weeks 17-20)

### Goal
Add shopping suggestions with affiliate revenue + optimize conversion funnels

### Features

#### 5.1 Affiliate Shopping Integration

**User Story**: "The AI suggested a beige blazer, but I don't have one. Where can I buy it?"

**Technical Implementation**:
```ruby
# app/services/shopping_suggestion_service.rb
class ShoppingSuggestionService
  AFFILIATE_PARTNERS = {
    amazon: { commission: 0.04, api_key: ENV['AMAZON_AFFILIATE_KEY'] },
    nordstrom: { commission: 0.05, api_key: ENV['NORDSTROM_AFFILIATE_KEY'] },
    asos: { commission: 0.08, api_key: ENV['ASOS_AFFILIATE_KEY'] }
  }

  def suggest_missing_items(outfit_suggestion)
    missing_categories = identify_gaps(outfit_suggestion)

    missing_categories.map do |category|
      # 1. Query affiliate APIs for matching items
      # 2. Filter by user's style preferences & budget
      # 3. Return 3-5 suggestions per category
      # 4. Include affiliate tracking links
    end
  end

  def identify_gaps(outfit_suggestion)
    # Compare outfit needs vs. user's wardrobe
    # Example: Outfit needs "blazer" but user has none
  end
end
```

**UI Components**:
- "Complete the Look" section below outfit suggestions
- Cards showing 3-5 product suggestions with images, prices, retailer
- CTA: "Shop at [Retailer]" (affiliate link)
- Disclosure: "We earn a small commission if you purchase"

**Tier Differentiation**:
- **Free**: See suggestions with ads + standard affiliate links
- **Premium**: Fewer ads, "Member perks" badge
- **Pro**: Ad-free, exclusive deals, early access notifications

**Revenue Model**:
- 1,000 users × 20% click rate × 5% purchase rate × $80 avg order × 6% commission = **$480/month**
- Scales linearly with user base

**Timeline**: 2-3 weeks

---

#### 5.2 Conversion Rate Optimization

**Goals**:
- Increase free → premium conversion from 6% to 8%+
- Reduce churn from 8% to 5%

**Tactics**:

**Better Upgrade Prompts**:
- Behavioral triggers (user hits limit 3 days in a row → show upgrade modal)
- Contextual value messaging ("Unlock weather-aware suggestions for your Chicago trip")
- A/B test messaging: "Upgrade" vs. "Unlock" vs. "Get Premium"

**Onboarding Improvements**:
- Force "upload 10 items" before AI suggestions (commitment)
- Guided first outfit creation
- Day 3 email: "Here's your first AI outfit for tomorrow"

**Retention Features**:
- Weekly recap email: "You styled 5 outfits this week! 🎉"
- Monthly "Wardrobe Wrapped" (Spotify-style stats)
- Daily push notification (opt-in): "Your outfit for today"

**Churn Prevention**:
- Cancel flow: Exit survey + offer downgrade to free
- Pause subscription option (1-3 months)
- Win-back email for inactive users

**Timeline**: Ongoing optimization

---

#### 5.3 Referral Program

**Mechanics**:
- Free user refers friend → both get 1-week Premium trial
- Premium user refers paying friend → referrer gets 1 month free
- Pro user refers paying friend → referrer gets $10 credit

**Implementation**:
```ruby
# app/models/referral.rb
class Referral < ApplicationRecord
  belongs_to :referrer, class_name: 'User'
  belongs_to :referred, class_name: 'User'

  enum status: { pending: 0, completed: 1, rewarded: 2 }

  def process_reward
    case referrer.subscription.tier
    when 'free'
      referred.grant_trial(days: 7)
      referrer.grant_trial(days: 7)
    when 'premium'
      referrer.extend_subscription(months: 1)
    when 'pro'
      referrer.add_credit(amount: 10.00)
    end

    update!(status: :rewarded)
  end
end
```

**UI**:
- Unique referral link per user
- "Refer & Earn" page showing pending/completed referrals
- Auto-apply rewards (no manual intervention)

**Target**: 0.3 viral coefficient (30% of users refer 1 person who signs up)

**Timeline**: 1 week

---

### Success Criteria (End of Phase 5)
- ✅ $5,000 MRR (600 Premium + 40 Pro + $500 affiliate)
- ✅ 8%+ free → premium conversion
- ✅ <6% monthly churn
- ✅ $200-500 monthly affiliate revenue
- ✅ 10,000+ total users

---

## Phase 6: Scale & Refine (Weeks 21+)

### Goal
Reach $10k MRR and optimize all funnels

### Key Activities

#### 6.1 Content Marketing for SEO
**Strategy**: Rank for "how to style [item]" queries

**Execution**:
- 2 blog posts per week (1,500 words each)
- Topics: "10 Ways to Style a White T-Shirt", "Business Casual for Women", "Capsule Wardrobe Guide"
- Target keywords: 10k-50k monthly search volume
- Include user-submitted outfit images

**Expected Impact**: 100-200 organic signups/month by month 12

**Timeline**: Ongoing, start week 21

---

#### 6.2 Influencer/Creator Partnerships

**Target**: Fashion micro-influencers (10k-100k followers), personal stylists

**Offer**:
- Free Pro account
- "Creator" badge
- 20% affiliate revenue share on referrals
- Early access to features

**Requirements**:
- 2 outfit tutorials per month featuring Outfit Maker
- Use unique referral code

**Expected Impact**:
- 10 creators × 50k followers × 0.1% conversion = 500 signups
- 30 paying customers/month at 6% conversion

**Timeline**: Start outreach week 21

---

#### 6.3 Advanced Analytics & Personalization

**Features**:
- Style insights: "You wear blue 40% of the time"
- Wardrobe gaps: "You're missing versatile black pants"
- Outfit performance: "This outfit got 15 likes when you shared it"
- Seasonal analysis: "Your winter wardrobe is 30% smaller than summer"

**Pro Tier Only**: Full analytics dashboard

**Timeline**: 2-3 weeks

---

#### 6.4 Mobile Native App Consideration

**Decision Point**: Only build if PWA adoption <50% after 6 months

**If building**:
- Use Turbo Native (Rails-powered native wrapper)
- Shares backend with web app
- Focus on iOS first (80% of fashion app revenue)
- 3-4 months development time

**Timeline**: TBD based on PWA metrics

---

### Success Criteria (Month 8-9 post-monetization)
- ✅ $10,000 MRR
- ✅ 1,150 Premium + 100 Pro subscribers
- ✅ 20,000+ total users
- ✅ Product-market fit validated (retention >25% Day 30)
- ✅ Decide: Raise funding OR stay profitable bootstrap

---

## Revenue Projections Summary

| Milestone | Timeline | MRR | Users (Total) | Paid Users | Notes |
|-----------|----------|-----|---------------|------------|-------|
| First Dollar | Week 11 | $8 | 500 | 1 | Validation |
| $1k MRR | Week 15 | $1,000 | 2,000 | 130 | Proof of concept |
| $5k MRR | Week 25 | $5,000 | 11,000 | 640 | Sustainability |
| $10k MRR | Week 41 | $10,000 | 21,000 | 1,250 | Full-time viable |

**Assumptions**:
- 6% free → premium conversion
- 20% premium → pro conversion
- 8% monthly churn (Premium), 5% (Pro)
- 30% annual plan adoption
- 350 new signups/week (weeks 9-25), scaling to 600/week (weeks 26-41)

---

## Cost Structure

### Fixed Costs (Monthly)
- Hosting (Railway/Heroku): $50-100
- Vertex AI base quota: $100
- Email service (Postmark): $25
- OpenWeather API: $0 (free tier)
- Domain/SSL: $10
- **Total Fixed**: $185-235/month

### Variable Costs (Per User/Month)
- **Free User**: $0.05 (storage, minimal AI)
- **Premium User**: $0.40 (30 AI suggestions × $0.01 + storage/email)
- **Pro User**: $1.50 (60 AI suggestions × $0.01 + 15 try-ons × $0.06 + storage)

### Gross Margins
- **Premium**: ($7.50 - $0.40) / $7.50 = **94.7%**
- **Pro**: ($13.98 - $1.50) / $13.98 = **89.3%**

### Breakeven
- **27 Premium subscribers** = $185 fixed costs covered
- **Profitable at**: 100 paying customers ($709 MRR, $325 profit)

---

## Risk Mitigation

### Risk 1: AI Costs Spiral
**Mitigation**:
- Rate limiting (3/day free, 30/day premium, 100/day pro soft limit)
- Response caching (24-hour TTL)
- Cost monitoring alerts at $500/month spend
- Flag users >150 requests/day for manual review

### Risk 2: High Churn
**Mitigation**:
- Onboarding optimization (force 10-item upload before AI)
- Habit formation (daily OOTD, weekly recap emails)
- Churn prediction (flag users <2 logins in 14 days)
- Cancel flow with downgrade offers

### Risk 3: Low Conversion
**Mitigation**:
- Generous free tier (prove value first)
- 14-day Premium trials
- Behavioral upgrade prompts (when hitting limits)
- Social proof ("2,847 users upgraded this month")

### Risk 4: Solo Founder Burnout
**Mitigation**:
- Self-service FAQ and help docs
- Community support (Discord for free users)
- Automated common fixes (password reset, retry uploads)
- Tiered support (free = community, premium = 48hr, pro = 12hr)
- Hire part-time VA at 5,000 users ($600/month)

---

## Tech Stack Decisions

### CONFIRMED: Rails + Hotwire (NO Next.js migration)
**Reasoning**:
- Already have momentum with Rails
- Hotwire perfect for this use case (real-time updates, drag-and-drop)
- Faster solo development vs. Rails API + Next.js frontend
- Can always add Next.js frontend later if needed

### CONFIRMED: NO Vite
**Reasoning**:
- esbuild via jsbundling-rails is sufficient
- Vite adds unnecessary complexity for Stimulus-light app
- Not building React-heavy SPA that needs Vite's HMR

### CONFIRMED: Stick with Vertex AI Gemini 2.5
**Reasoning**:
- Already integrated and working
- Multimodal (vision + text) perfect for fashion
- Cost-effective ($0.01 per request)
- Embeddings working with pgvector

### CONFIRMED: FASHN API for Virtual Try-On (NOT custom model)
**Reasoning**:
- Building custom virtual try-on requires $50k-250k investment
- FASHN API: $0.04-0.075/image, professional quality
- 5-17 second processing vs. 30-60 seconds DIY
- Can self-host later if volume justifies (100k+ renders/month)

---

## Next Steps (Immediate Actions)

### Week 1-2: Context-Based Recommendations MVP
1. Build `OutfitSuggestionService` (2 days)
2. Create `/outfits/suggest` endpoint + UI (3 days)
3. Implement rate limiting (3/day free tier) (1 day)
4. Add prominent CTA on dashboard (1 day)
5. Test with 20 beta users, gather feedback (3 days)

### Week 3-4: Instrumentation & Iteration
1. Set up Mixpanel/Plausible analytics (1 day)
2. Track key events (signup, upload, AI suggestion, outfit save) (1 day)
3. User interviews (30 users) - validate willingness to pay (ongoing)
4. Iterate on suggestion quality based on feedback (1 week)
5. Prepare for Phase 2 (user profiles migration, weather service setup)

---

## Key Performance Indicators (Weekly Dashboard)

| Category | Metric | Target | Red Flag |
|----------|--------|--------|----------|
| **Acquisition** | New signups/week | 350+ | <200 |
| | Signup → 10 items uploaded | 60% | <40% |
| **Activation** | Week 1 retention | 50% | <35% |
| | Week 4 retention | 30% | <20% |
| **Engagement** | WAU/MAU ratio | 40%+ | <25% |
| | AI suggestions/user/week | 5+ | <2 |
| **Monetization** | Free → Premium | 6% | <3% |
| | Premium → Pro | 20% | <10% |
| **Retention** | Monthly churn (Premium) | <8% | >12% |
| | Monthly churn (Pro) | <5% | >10% |
| **Unit Economics** | CAC | <$15 | >$30 |
| | LTV | $180+ | <$90 |
| | LTV:CAC | 12:1+ | <6:1 |

---

## Final Recommendations

### DO THIS NOW:
1. **Build context-based outfit recommendations** (Weeks 1-4)
2. **Get 200 beta users who love fashion** (friends, family, Reddit r/femalefashionadvice)
3. **Validate retention >50% Week 1** before building more features
4. **Set up analytics** (Mixpanel) - measure everything

### DON'T DO (Yet):
1. ❌ Build virtual try-on yourself (use FASHN API in Phase 4)
2. ❌ Switch to Next.js (waste of time)
3. ❌ Add Vite (unnecessary complexity)
4. ❌ Build social features (premature)
5. ❌ Launch monetization before Phase 1 validation

### QUESTION TO ASK BEFORE EVERY FEATURE:
**"Will this help users solve 'What should I wear today?' faster and better?"**

If the answer isn't a clear YES, defer it.

---

## Competitive Positioning

| Feature | Stylebook | Cladwell | Outfit Maker |
|---------|-----------|----------|--------------|
| Price | $4.99/mo | $5/mo | $7.99/$14.99 |
| AI Recommendations | ❌ | Limited | ✅ Context-aware |
| Virtual Try-On | ❌ | ❌ | ✅ (Pro tier) |
| Image Search | ❌ | ❌ | ✅ |
| Weather Integration | Manual | Basic | ✅ Automatic |
| Auto-Tagging | ❌ | ❌ | ✅ AI-powered |
| Modern UI | Dated | Okay | ✅ Tailwind v4 |
| Tech Stack | Native iOS | React | Rails + Hotwire |

**Positioning**: Premium AI-first fashion assistant (60-200% price premium justified by AI capabilities)

**Target User**: Fashion-conscious professionals, 25-45, willing to pay $8-15/month for convenience + confidence

---

**Status**: Ready to implement Phase 1 (Weeks 1-4)

**Last Updated**: 2025-12-04
