# Phase 4: AI Shopping + Affiliate Revenue - Deployment Guide

## Overview

Phase 4 adds the "Complete Your Look" shopping recommendation feature to the Outfit app. This feature uses AI to identify missing items from a user's wardrobe and recommends Amazon affiliate products to complete their outfits.

## Features Implemented

### 1. Missing Item Detection (CHUNK 2)
- **Service**: `MissingItemDetector`
- **AI Model**: Google Gemini 2.5 Flash
- **Purpose**: Analyzes user's wardrobe and outfit context to identify 1-3 missing essential items

### 2. AI Product Image Generation (CHUNK 3)
- **Service**: `ProductImageGenerator`
- **AI Model**: Replicate SDXL (Stability AI)
- **Purpose**: Generates professional product photography images for missing items
- **Background Job**: `GenerateProductImageJob`

### 3. Amazon Product Matching (CHUNK 4)
- **Service**: `AmazonProductMatcher`
- **API**: Amazon Product Advertising API 5.0 (via `paapi` gem)
- **Purpose**: Fetches affiliate products from Amazon matching missing items
- **Background Job**: `FetchAffiliateProductsJob`

### 4. Controller Integration (CHUNK 5)
- **Controller**: `OutfitSuggestionsController`
- **New Actions**:
  - `show_recommendations` - Display product recommendations
  - `record_view` - Track product recommendation views
  - `record_click` - Track affiliate link clicks
- **Workflow**: Automatically triggered after outfit suggestion creation

### 5. Frontend UI (CHUNK 6)
- **Views**:
  - `app/views/outfit_suggestions/show.html.erb` - "Complete Your Look" section
  - `app/views/outfit_suggestions/show_recommendations.html.erb` - Turbo Frame view
  - `app/views/product_recommendations/_recommendation.html.erb` - Recommendation card
  - `app/views/product_recommendations/_affiliate_product.html.erb` - Amazon product card
- **Stimulus Controller**: `product_recommendation_controller.js` - Analytics tracking
- **Features**:
  - Lazy loading with Turbo Frames
  - AI-generated product images
  - Amazon affiliate product grid
  - Real-time analytics tracking
  - Responsive design

### 6. Admin Analytics Dashboard (CHUNK 7)
- **Controller**: `Admin::ProductRecommendationsController`
- **Route**: `/admin/product_recommendations`
- **Features**:
  - Summary cards (total views, clicks, conversions, revenue)
  - Advanced filtering (category, priority, date range, performance)
  - Sorting (views, clicks, CTR, revenue, conversion rate)
  - CSV export
  - Responsive table with analytics metrics

### 7. Database Schema (CHUNK 1)
- **Table**: `product_recommendations`
- **Key Fields**:
  - Missing item details (category, description, color_preference, style_notes, reasoning)
  - Priority enum (high, medium, low)
  - Budget range enum (budget, mid_range, premium, luxury)
  - AI image fields (url, status, cost, error)
  - JSONB affiliate_products array
  - Analytics fields (views, clicks, conversions, revenue_earned)
- **Indexes**: 8 comprehensive indexes for optimal query performance

### 8. Comprehensive Testing (CHUNK 8)
- **Integration Tests**: Full workflow from outfit suggestion to product display
- **Request Specs**: Admin dashboard and analytics tracking
- **Service Specs**: All AI services with mocked API responses
- **Job Specs**: Background job execution and retry logic
- **Coverage**: Error scenarios and graceful degradation

## Environment Variables Required

Add these to your `.env` file:

```bash
# Google Cloud AI Platform (for Gemini)
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_CREDENTIALS=/path/to/credentials.json

# Replicate (for SDXL image generation)
REPLICATE_API_TOKEN=your_replicate_api_token

# Amazon Product Advertising API
AMAZON_ACCESS_KEY=your_access_key
AMAZON_SECRET_KEY=your_secret_key
AMAZON_ASSOCIATE_TAG=your_associate_tag
# Optional:
# AMAZON_PARTNER_TYPE=Associates
# AMAZON_MARKETPLACE=www.amazon.com
```

## Deployment Steps

### 1. Database Migration

```bash
# Check migration status
RAILS_ENV=production bin/rails db:migrate:status

# Run the migration
RAILS_ENV=production bin/rails db:migrate

# Verify schema
RAILS_ENV=production bin/rails db:schema:dump
```

The migration creates the `product_recommendations` table with all necessary fields and indexes.

### 2. Install Dependencies

The following gems were added to the Gemfile:

```ruby
# Already included (no changes needed):
gem 'httparty'           # For HTTP requests
gem 'googleauth'         # For Google Cloud authentication
gem 'kaminari'           # For pagination

# New dependency:
gem 'paapi', '~> 1.0'    # Amazon Product Advertising API
```

Run:
```bash
bundle install
```

### 3. Configure API Credentials

#### Google Cloud (Gemini)
1. Create a Google Cloud project at https://console.cloud.google.com
2. Enable the "Vertex AI API"
3. Create a service account with "Vertex AI User" role
4. Download JSON credentials
5. Set `GOOGLE_CLOUD_PROJECT` and `GOOGLE_CLOUD_CREDENTIALS` environment variables

#### Replicate (SDXL)
1. Sign up at https://replicate.com
2. Get your API token from https://replicate.com/account/api-tokens
3. Set `REPLICATE_API_TOKEN` environment variable

#### Amazon Product Advertising API
1. Sign up for Amazon Associates at https://affiliate-program.amazon.com
2. Apply for Product Advertising API access
3. Get access credentials (Access Key, Secret Key, Associate Tag)
4. Set environment variables: `AMAZON_ACCESS_KEY`, `AMAZON_SECRET_KEY`, `AMAZON_ASSOCIATE_TAG`

### 4. Background Jobs

Ensure your background job processor (Sidekiq) is running:

```bash
# Start Sidekiq
bundle exec sidekiq -C config/sidekiq.yml

# Or with systemd:
sudo systemctl start sidekiq
```

The following jobs will be enqueued automatically:
- `GenerateProductImageJob` - Generates AI images for recommendations
- `FetchAffiliateProductsJob` - Fetches Amazon affiliate products

### 5. Asset Compilation

```bash
# Precompile assets
RAILS_ENV=production bin/rails assets:precompile

# Or if using Vite:
RAILS_ENV=production bin/vite build
```

### 6. Server Restart

```bash
# Restart Rails server
sudo systemctl restart puma

# Or if using Passenger:
touch tmp/restart.txt
```

### 7. Verify Deployment

1. **Create a test outfit suggestion**
   - Log in as a user
   - Create an outfit suggestion
   - Verify the "Complete Your Look" section appears

2. **Check background jobs**
   - Monitor Sidekiq dashboard at `/sidekiq` (if enabled)
   - Verify `GenerateProductImageJob` and `FetchAffiliateProductsJob` are processing

3. **Verify admin analytics**
   - Log in as admin
   - Navigate to `/admin/product_recommendations`
   - Verify analytics dashboard loads with data

4. **Test analytics tracking**
   - View a product recommendation (should increment views)
   - Click a "Shop Now" button (should increment clicks)
   - Check `/admin/product_recommendations` for updated metrics

## Monitoring

### Logs to Monitor

```bash
# Rails logs
tail -f log/production.log | grep -i "product.*recommendation"

# Sidekiq logs
tail -f log/sidekiq.log | grep -E "(GenerateProductImageJob|FetchAffiliateProductsJob)"

# Bullet gem (N+1 query detection)
tail -f log/bullet.log
```

### Key Metrics

- **Product Recommendation Creation Rate**: How many recommendations are generated per outfit suggestion
- **AI Image Success Rate**: Percentage of images successfully generated (target: >95%)
- **Amazon Product Match Rate**: Percentage of recommendations with affiliate products (target: >90%)
- **Click-Through Rate (CTR)**: Clicks / Views (target: >5%)
- **Conversion Rate**: Conversions / Clicks (target: >10%)
- **Revenue per Conversion**: Average commission earned per purchase

### Error Scenarios

**Missing Item Detection Failures:**
- Logs: `"Failed to detect missing items"`
- Impact: No product recommendations created (outfit suggestion still succeeds)
- Action: Check Google Cloud credentials and API quotas

**Image Generation Failures:**
- Logs: `"Image generation failed"`
- Impact: Product recommendation created without AI image
- Action: Check Replicate API token and credits

**Amazon API Failures:**
- Logs: `"Failed to fetch affiliate products"`
- Impact: Product recommendation created without affiliate products
- Action: Check Amazon API credentials and request limits

## Cost Estimates

### Per Outfit Suggestion (with 2 missing items detected)

| Service | Operation | Cost | Notes |
|---------|-----------|------|-------|
| Gemini 2.5 Flash | Missing item detection | ~$0.0001 | 500 tokens output |
| Replicate SDXL | Image generation (2x) | $0.0050 | $0.0025 per image |
| Amazon PA-API | Product search (2x) | $0.0000 | Free tier (8,640 requests/day) |
| **Total** | **Per outfit suggestion** | **~$0.0051** | |

### Monthly Estimates (1,000 outfit suggestions)

- AI Costs: ~$5.10/month
- Revenue Potential: $50-150/month (assuming 5% CTR, 10% conversion, 5% commission)
- **Net Revenue**: $45-145/month

## Rollback Plan

If issues arise, rollback is straightforward:

```bash
# 1. Stop background jobs
sudo systemctl stop sidekiq

# 2. Rollback database migration
RAILS_ENV=production bin/rails db:rollback STEP=1

# 3. Restore previous code version
git checkout <previous-commit>

# 4. Restart services
sudo systemctl restart puma
sudo systemctl start sidekiq
```

## Future Enhancements

1. **Real-time Image Updates**: Use Turbo Streams to update images when generation completes
2. **Personalized Recommendations**: Use user's purchase history and preferences
3. **Multiple Marketplace Support**: Add support for other affiliate networks (Walmart, Target, etc.)
4. **A/B Testing**: Test different recommendation algorithms and UI variations
5. **Email Notifications**: Send weekly "Complete Your Look" emails with recommendations
6. **Social Sharing**: Allow users to share their shopping recommendations

## Support

For issues or questions:
- Check logs in `log/production.log` and `log/sidekiq.log`
- Review integration tests in `spec/integration/product_recommendation_workflow_spec.rb`
- Contact the development team

---

**Deployment completed on**: [Date]
**Deployed by**: [Your Name]
**Version**: Phase 4.0
**Git commit**: `git rev-parse HEAD`
