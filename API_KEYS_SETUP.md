# API Keys Setup Guide - Outfitmaker

This guide will help you set up all required API keys for your Outfitmaker application.

## Required API Keys

### 1. Google Cloud (Gemini AI) - REQUIRED
**Purpose:** AI outfit suggestions and image analysis

**Steps:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable "Vertex AI API"
4. Go to "APIs & Services" → "Credentials"
5. Create credentials → "API Key"
6. Copy the API key

**Environment Variables:**
```bash
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

**Cost:** Pay-as-you-go. Gemini 2.5 Flash is very affordable (~$0.01 per 1000 requests)

---

### 2. RapidAPI (Amazon Product Data) - REQUIRED
**Purpose:** Fetch Amazon affiliate products for outfit recommendations

**Steps:**
1. Go to [RapidAPI Hub](https://rapidapi.com/hub)
2. Create account / Sign in
3. Search for "Real-Time Amazon Data"
4. Subscribe to a plan (Basic plan usually sufficient)
5. Go to "Endpoints" → Copy your API key

**Environment Variables:**
```bash
RAPIDAPI_KEY=your-rapidapi-key-here
RAPIDAPI_HOST=real-time-amazon-data.p.rapidapi.com
```

**Cost:** Free tier available (500 requests/month), Paid plans from $10/month

---

### 3. Amazon Associates - REQUIRED
**Purpose:** Earn commission from Amazon product recommendations

**Steps:**
1. Go to [Amazon Associates](https://affiliate-program.amazon.com/)
2. Sign up for the program (requires approval)
3. Create your Associate ID/Tag (looks like: `yourname-20`)
4. Get approved (may take 24-48 hours)

**Environment Variables:**
```bash
AMAZON_ASSOCIATE_TAG=your-tag-here
# Optional: Set default marketplace (US, UK, DE, FR, etc.)
AMAZON_MARKETPLACE=US
```

**Note:** App automatically detects user's marketplace from their location (Paris → Amazon.fr, London → Amazon.co.uk)

**Cost:** Free to join. You earn 1-10% commission on sales.

---

### 4. Google AdSense - REQUIRED (for monetization)
**Purpose:** Display ad banners to free-tier users

**Steps:**
1. Go to [Google AdSense](https://www.google.com/adsense)
2. Sign up for an account (requires website approval)
3. Submit your website for review (may take days to weeks)
4. Once approved, create ad units:
   - **Desktop Ad**: 728x90 leaderboard banner
   - **Mobile Ad**: 320x50 mobile banner
5. Copy your Client ID (looks like: `ca-pub-xxxxxxxxxxxxxxxxx`)
6. Copy your Ad Slot IDs for each ad unit

**Environment Variables:**
```bash
GOOGLE_ADSENSE_CLIENT_ID=ca-pub-xxxxxxxxxxxxxxxxx
GOOGLE_ADSENSE_SLOT_ID=1234567890              # Desktop ad slot ID
GOOGLE_ADSENSE_MOBILE_SLOT_ID=0987654321       # Mobile ad slot ID
```

**Cost:** Free to join. You earn revenue from ads (typically $0.50-$5 CPM)

**Important Notes:**
- **Requires approval** - Google reviews your site for quality, traffic, and content
- **Traffic required** - Need decent traffic for approval (varies, but usually 100+ daily visitors)
- **Ad placement** - Ads show ONLY to free-tier users (see `app/views/shared/_ad_banner.html.erb`)
- **Premium users** - Premium subscribers see NO ads
- **Revenue tracking** - App tracks ad impressions and clicks via `AdImpression` model

**Without AdSense:**
- App will show placeholder banners (see development preview)
- No actual ads served until you add credentials
- Premium subscriptions still work

---

### 5. Replicate AI - OPTIONAL (NOT REQUIRED - using local Python)
**Purpose:** Background removal for product images

**Current Setup:** The app uses **local Python (rembg)** for background removal, so you DON'T need a Replicate API key.

**If you want to use Replicate instead:**
1. Go to [Replicate](https://replicate.com/)
2. Sign up / Log in
3. Go to Account Settings → API Tokens
4. Create new token
5. Copy the token

**Environment Variables:**
```bash
REPLICATE_API_TOKEN=your-replicate-token-here
```

**Cost:** Pay-as-you-go. Background removal ~$0.002 per image

**Note:** Local Python solution is FREE but uses server CPU. Replicate is paid but offloads processing.

---

### 6. OpenWeather API - OPTIONAL
**Purpose:** Weather-aware outfit suggestions

**Steps:**
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for free account
3. Go to API keys section
4. Copy your API key (may take a few hours to activate)

**Environment Variables:**
```bash
OPENWEATHER_API_KEY=your-openweather-key-here
```

**Cost:** Free tier (1000 calls/day) is usually sufficient

**Note:** Without this, app still works but won't provide weather-based recommendations

---

### 7. Stripe - OPTIONAL (for payments)
**Purpose:** Handle subscription payments

**Steps:**
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Sign up / Log in
3. Get your API keys from Developers → API keys
4. Use test keys for development, live keys for production

**Environment Variables:**
```bash
# Test keys (for development)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Production keys (for live site)
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

**Cost:** 2.9% + $0.30 per transaction

---

### 8. Web Push (VAPID Keys) - OPTIONAL
**Purpose:** Send push notifications to users

**Steps:**
```bash
# Run in Rails console
rails console
vapid_key = WebPush.generate_key
puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"
```

**Environment Variables:**
```bash
VAPID_PUBLIC_KEY=your-public-key-here
VAPID_PRIVATE_KEY=your-private-key-here
VAPID_SUBJECT=mailto:your-email@example.com
```

**Cost:** Free

---

## Setting Environment Variables

### Development (.env file)
```bash
# Create a .env file in your project root
cp .env.example .env

# Edit .env and add your keys
nano .env
```

### Production (Recommended Hosting)

#### **Railway (RECOMMENDED)**
- **Pros:**
  - Free tier ($5 credit/month)
  - Simple deployment from GitHub
  - Built-in PostgreSQL
  - Auto SSL certificates
  - Great for mobile app backends (stable API endpoints)
  - Easy environment variable management
  - Automatic deployments on git push

- **Setup:**
  1. Go to [Railway.app](https://railway.app/)
  2. Connect your GitHub repo
  3. Add PostgreSQL service
  4. Add environment variables in dashboard
  5. Deploy!

**Cost:** Free tier, then $5/month base + usage

---

#### **Render (Alternative)**
- **Pros:**
  - Free tier available
  - Auto SSL
  - PostgreSQL included
  - Good for mobile app backends

**Cost:** Free tier (slow), paid plans from $7/month

---

#### **Heroku (Classic Choice)**
- **Pros:**
  - Well-documented
  - Huge ecosystem
  - Great for Rails

- **Cons:**
  - No free tier anymore
  - More expensive

**Cost:** From $7/month

---

## Mobile App Considerations

If you plan to create iOS/Android apps later:

### React Native / Flutter APIs
Your Rails app can serve as the backend API. All these providers work well:
- **Railway** ✅ Best choice - stable endpoints, good performance
- **Render** ✅ Good choice
- **Heroku** ✅ Good choice

### What you'll need:
1. Stable API endpoint (https://your-app.railway.app)
2. API authentication (currently uses session cookies, may need JWT)
3. Mobile-friendly JSON responses (already implemented with Turbo)

---

## Deployment Checklist

Before deploying to production:

**Required API Keys:**
- [ ] Google Cloud (Gemini AI) - for outfit suggestions
- [ ] RapidAPI - for Amazon product data
- [ ] Amazon Associate Tag - for affiliate links
- [ ] Google AdSense - for ad revenue (requires site approval)

**Optional but Recommended:**
- [ ] OpenWeather API - for weather-based suggestions
- [ ] Stripe - for premium subscriptions
- [ ] VAPID keys - for push notifications

**Hosting Setup:**
- [ ] Choose hosting provider (Railway recommended)
- [ ] Set environment variables in hosting dashboard
- [ ] Run database migrations: `rails db:migrate`
- [ ] Precompile assets: `rails assets:precompile`
- [ ] Set `RAILS_ENV=production`
- [ ] Set `RAILS_MASTER_KEY` or `SECRET_KEY_BASE`

**Post-Deployment:**
- [ ] Apply for Google AdSense (submit site for review)
- [ ] Test ad placements appear correctly
- [ ] Verify Amazon affiliate links work
- [ ] Monitor ad impressions in admin dashboard

---

## Security Notes

⚠️ **NEVER commit API keys to git!**

- Add `.env` to `.gitignore` (should already be there)
- Use Rails credentials for sensitive data in production
- Rotate keys if accidentally exposed
- Use test keys for development

---

## Monetization Summary

**Two revenue streams:**
1. **Amazon Affiliate** - Earn 1-10% commission on product sales
2. **Google AdSense** - Earn $0.50-$5 CPM from ad impressions (free users only)

**Premium subscriptions** remove ads and unlock premium features via Stripe.

---

## Cost Estimate

**Minimum monthly cost to run:**
- Hosting: $0-7/month (Railway free tier or Render/Heroku paid)
- Google Cloud (Gemini AI): ~$5-20/month (depending on usage)
- RapidAPI (Amazon data): $10/month (Basic plan)
- Background removal: FREE (local Python rembg)
- OpenWeather: FREE (free tier)
- Google AdSense: FREE (you earn money)
- Stripe: Only 2.9% + $0.30 per transaction
- **Total: ~$15-37/month** for moderate usage

**Revenue potential:**
- Amazon affiliate: Variable (depends on sales)
- Google AdSense: Variable (depends on traffic, typically $50-500/month with decent traffic)
- Premium subscriptions: Variable (depends on conversion rate)

---

## Testing Your Setup

Run this to verify your API keys:

```bash
rails console

# Test Google Cloud (Gemini AI)
user = User.first
OutfitSuggestionService.new(user, "casual outfit").generate_suggestion

# Test RapidAPI (Amazon products)
ProductRecommendation.first&.affiliate_products

# Test Weather API
WeatherService.new("Paris, France").current_conditions

# Test Background Removal (local Python)
# Upload an image through the UI and check background removal works

# Test Google AdSense
# Visit the app as a free-tier user - you should see ad placeholders
# Once AdSense credentials are added, real ads will appear

# Test Stripe
# Go to /subscription page and test payment flow

# Test Admin Dashboard (Ad Analytics)
# Login as admin and visit /admin to see ad impression tracking
```

---

## Support

If you encounter issues:
1. Check logs: `rails logs` or hosting dashboard logs
2. Verify API key format (no extra spaces, correct key)
3. Check API usage limits
4. Verify billing is set up (Google Cloud, RapidAPI)

---

**Ready to deploy? Choose Railway for the best mobile app backend experience!**
