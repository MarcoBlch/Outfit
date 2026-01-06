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

### 4. Replicate AI - REQUIRED
**Purpose:** Background removal for product images

**Steps:**
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

---

### 5. OpenWeather API - OPTIONAL
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

### 6. Stripe - OPTIONAL (for payments)
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

### 7. Web Push (VAPID Keys) - OPTIONAL
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

- [ ] Get all REQUIRED API keys
- [ ] Set up Stripe (if monetizing)
- [ ] Generate VAPID keys (if using push notifications)
- [ ] Set up Weather API (optional but recommended)
- [ ] Choose hosting provider
- [ ] Set environment variables in hosting dashboard
- [ ] Run database migrations: `rails db:migrate`
- [ ] Precompile assets: `rails assets:precompile`
- [ ] Set `RAILS_ENV=production`
- [ ] Set `RAILS_MASTER_KEY` or `SECRET_KEY_BASE`

---

## Security Notes

⚠️ **NEVER commit API keys to git!**

- Add `.env` to `.gitignore` (should already be there)
- Use Rails credentials for sensitive data in production
- Rotate keys if accidentally exposed
- Use test keys for development

---

## Cost Estimate

**Minimum monthly cost to run:**
- Hosting: $0-7/month (Railway free tier or Render/Heroku paid)
- Google Cloud: ~$5-20/month (depending on usage)
- RapidAPI: $10/month (Basic plan)
- Replicate: ~$5-15/month (depending on image uploads)
- OpenWeather: Free
- Stripe: Only % of transactions
- **Total: ~$20-50/month** for moderate usage

---

## Testing Your Setup

Run this to verify your API keys:

```bash
rails console

# Test Google Cloud
user = User.first
OutfitSuggestionService.new(user, "casual outfit").generate_suggestion

# Test RapidAPI
ProductRecommendation.first&.affiliate_products

# Test Weather
WeatherService.new("Paris, France").current_conditions

# Test Replicate
# Upload an image through the UI

# Test Stripe
# Go to /subscription page
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
