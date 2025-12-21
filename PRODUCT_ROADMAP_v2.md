# Outfit Maker: Complete Product & Monetization Roadmap v2

## Executive Summary

**Vision**: AI-powered fashion assistant that helps users create outfits from their existing wardrobe with context-aware recommendations, virtual try-on, and AI-powered shopping suggestions with affiliate revenue.

**Tech Stack**: Rails 7 + Hotwire (Turbo/Stimulus) + Tailwind CSS v4 + Vertex AI (Gemini 2.5 Flash) + Replicate (Stable Diffusion SDXL/Flux)

**Business Model**:
- 3-tier SaaS (Free / Premium $7.99/mo / Pro $14.99/mo)
- Affiliate Revenue (Amazon Associates 4-10% commission)
- Optional: Google AdSense on free tier pages ($500-2,000/month supplemental)

**Target**: $10k MRR by Week 41 (8 months post-monetization)

**Key Differentiator**: First AI stylist with "Complete Your Look" shopping + personalized avatar try-on

---

## What's Changed in V2?

### MAJOR REVISION: Phase 4 & 5 Swapped

**OLD Phase 4**: Virtual Try-On with FASHN API ($0.06/render, limited to 15/month Pro tier)
**NEW Phase 4**: AI-Generated Shopping + Affiliate Revenue (unlimited, all tiers)

**OLD Phase 5**: Shopping Integration
**NEW Phase 5**: Personalized Avatar Virtual Try-On (game-changer feature)

**Reasoning**:
1. **Shopping has better unit economics**: Affiliate revenue scales infinitely vs. per-render costs
2. **Broader appeal**: All users benefit from shopping suggestions vs. Pro-only try-on
3. **Revenue validation**: Prove affiliate model works before investing in avatar system
4. **Logical progression**: Shopping recommendations → avatar try-on feels more natural

---

## Phase 4 (NEW): AI Shopping + Affiliate Revenue (Weeks 13-18)

### Goal
Transform from "closet organizer" to "AI shopping assistant" while generating affiliate revenue from every outfit suggestion

### The Killer Feature: "Complete Your Look"

**User Story**:
> "I'm getting outfit suggestions for a job interview, but the AI says I'm missing a structured blazer. I want to see what blazer would work AND where to buy it."

**The Magic Workflow**:

1. **User requests outfit** → AI generates 3 suggestions from wardrobe
2. **AI detects gaps** → "This outfit would be perfect with a navy structured blazer"
3. **AI generates product image** → Shows photorealistic blazer matching user's style
4. **Real products appear** → 3 Amazon affiliate links to buy similar blazers
5. **User clicks & buys** → You earn 4-10% commission

**Visual Flow**:
```
[Outfit Suggestion Card]
  ├── Your current items (from wardrobe)
  ├── ✨ Complete Your Look ✨
  │   ├── [AI-Generated Product Image]
  │   │   → "Navy structured single-breasted blazer"
  │   └── [3 Real Products to Buy]
  │       ├── Theory Blazer - $425 (Amazon Prime)
  │       ├── Banana Republic - $179
  │       └── J.Crew - $148
  └── [Try On Avatar] → (Phase 5 feature teaser)
```

---

### Technical Implementation

#### Component 1: Missing Item Detection (Gemini 2.5 Flash)

**Purpose**: Identify 1-3 high-impact items missing from user's wardrobe

```ruby
# app/services/missing_item_detector.rb
class MissingItemDetector
  def initialize(user, outfit_suggestion, context)
    @user = user
    @outfit = outfit_suggestion
    @context = context
  end

  def detect(max_items: 3)
    prompt = build_detection_prompt
    response = call_gemini_api(prompt)

    parse_missing_items(response).first(max_items)
  end

  private

  def build_detection_prompt
    <<~PROMPT
      ROLE: Expert fashion stylist analyzing outfit completeness

      OUTFIT CONTEXT: #{@context}
      SUGGESTED ITEMS: #{@outfit.items.map{|i| "#{i.category} (#{i.color})"}.join(", ")}

      USER PROFILE:
      - Presentation style: #{@user.user_profile.presentation_style}
      - Age: #{@user.user_profile.age_range}
      - Style: #{@user.user_profile.style_preference}
      - Favorite colors: #{@user.user_profile.favorite_colors.join(", ")}

      TASK: Identify 1-3 items that would SIGNIFICANTLY improve this outfit.

      PRIORITIZATION:
      1. High-impact items (blazer > belt for professional context)
      2. Match user's presentation style & color preferences
      3. Elevate occasion appropriateness
      4. Fill wardrobe gaps (missing categories)

      RETURN JSON ARRAY (max 3 items, ordered by priority):
      [
        {
          "category": "blazer",
          "description": "Navy structured single-breasted blazer with notch lapels",
          "color_preference": "navy or charcoal",
          "style_notes": "Feminine cut with tailored waist, professional",
          "reasoning": "Elevates business casual to interview-appropriate formality. Navy matches existing favorite colors.",
          "priority": "high",
          "budget_range": "mid" // low ($50-100), mid ($100-300), high ($300+)
        }
      ]

      RULES:
      - Only suggest items NOT in user's wardrobe
      - Match their presentation style (don't suggest masculine items for feminine presentation)
      - Stay within realistic budget for their age/style tier
      - Provide specific, shoppable descriptions
    PROMPT
  end

  def parse_missing_items(response)
    JSON.parse(response)
  rescue JSON::ParserError
    []
  end
end
```

**Cost**: ~$0.0015 per detection (runs once per outfit suggestion)

---

#### Component 2: AI Product Image Generation (Replicate SDXL)

**Purpose**: Create photorealistic product visualization of the missing item

**Why Generate Instead of Just Show Real Products?**
- **Perfectly matches user's aesthetic**: AI generates in their favorite colors & style
- **Creates desire**: Custom visualization feels more personal than generic product photos
- **Unique value prop**: No competitor does this
- **Bridges the gap**: "This is what's missing" before showing what to buy

```ruby
# app/services/ai_product_image_service.rb
class AiProductImageService
  REPLICATE_API = "https://api.replicate.com/v1/predictions"

  def initialize
    @api_token = ENV['REPLICATE_API_TOKEN']
  end

  def generate_product_image(missing_item, user_profile)
    prompt = build_product_prompt(missing_item, user_profile)

    response = HTTParty.post(
      REPLICATE_API,
      headers: {
        'Authorization' => "Token #{@api_token}",
        'Content-Type' => 'application/json'
      },
      body: {
        version: "stability-ai/sdxl:39ed52f2...", # SDXL model ID
        input: {
          prompt: prompt,
          negative_prompt: "low quality, blurry, distorted, model, person, mannequin",
          width: 768,
          height: 768,
          num_outputs: 1,
          guidance_scale: 7.5,
          num_inference_steps: 40
        }
      }.to_json
    )

    # Poll for result (async processing, ~8-15 seconds)
    prediction_url = response['urls']['get']
    wait_for_completion(prediction_url)
  end

  private

  def build_product_prompt(item, profile)
    # Build detailed prompt based on item and user profile
    <<~PROMPT
      Professional product photography of a #{item['description']}.

      PRODUCT SPECS:
      - Item: #{item['category']}
      - Color: #{item['color_preference']}
      - Style: #{item['style_notes']}
      - Aesthetic: #{profile.presentation_style} presentation

      PHOTOGRAPHY REQUIREMENTS:
      - Clean white studio background
      - Professional lighting with soft shadows
      - Front view, hanging or flat lay
      - High-resolution ecommerce product shot
      - Sharp focus on fabric texture and details
      - No model, mannequin, or person visible
      - Professional fashion photography style

      The #{item['category']} should look like a premium retail product photo.
      Photorealistic, 8K quality, sharp details.
    PROMPT
  end

  def wait_for_completion(prediction_url)
    60.times do # Max 60 seconds timeout
      sleep 1
      response = HTTParty.get(prediction_url, headers: {
        'Authorization' => "Token #{@api_token}"
      })

      if response['status'] == 'succeeded'
        return {
          url: response['output'][0],
          cost: 0.0024 # SDXL Pro pricing
        }
      elsif response['status'] == 'failed'
        raise "Image generation failed: #{response['error']}"
      end
    end

    raise "Timeout waiting for image generation"
  end
end
```

**Cost**: $0.0024 per image (SDXL)
**Alternative**: Flux Pro ($0.04/image) for higher quality if users complain

**Why This Cost is Acceptable**:
- Runs ONLY when AI detects missing items (~30% of suggestions)
- 1,000 suggestions → 300 with shopping → 300 × $0.0024 = **$0.72 cost**
- If just 1 person buys a $100 blazer → $8 commission → **11x ROI**

---

#### Component 3: Affiliate Product Matching (Amazon Product Advertising API)

**Purpose**: Match AI-generated concept to real purchasable products

```ruby
# app/services/product_recommendation_service.rb
class ProductRecommendationService
  def initialize
    Amazon::Ecs.configure do |options|
      options[:associate_tag] = ENV['AMAZON_ASSOCIATE_TAG']
      options[:AWS_access_key_id] = ENV['AMAZON_ACCESS_KEY']
      options[:AWS_secret_key] = ENV['AMAZON_SECRET_KEY']
    end
  end

  def find_matching_products(missing_item, limit: 3)
    search_query = build_search_query(missing_item)

    response = Amazon::Ecs.item_search(
      search_query,
      response_group: 'Medium,Images,ItemAttributes,Offers',
      search_index: 'Fashion',
      sort: 'relevancerank'
    )

    # Parse and return top matches
    response.items.first(limit).map do |item|
      {
        title: item.get('ItemAttributes/Title'),
        image_url: item.get('LargeImage/URL'),
        price: item.get('OfferSummary/LowestNewPrice/FormattedPrice'),
        affiliate_url: item.get('DetailPageURL'), # Auto-includes your associate tag
        rating: item.get('CustomerReviews/AverageRating'),
        prime_eligible: item.get('OfferSummary/IsPrime') == '1',
        brand: item.get('ItemAttributes/Brand')
      }
    end
  end

  private

  def build_search_query(item)
    # Combine category + color + style for precise matching
    keywords = [
      item['category'],
      item['color_preference'],
      extract_style_keywords(item['style_notes'])
    ].compact.join(" ")

    # Add quality filters
    "#{keywords} #{target_brands(item)}"
  end

  def extract_style_keywords(style_notes)
    # "Feminine cut with tailored waist, professional"
    # → "tailored professional"
    style_notes.scan(/\b(tailored|structured|casual|formal|slim|fitted|relaxed)\b/).flatten.first(2).join(" ")
  end

  def target_brands(item)
    # Smart brand targeting based on budget
    case item['budget_range']
    when 'low'
      "Amazon Essentials OR Goodthreads OR Daily Ritual"
    when 'mid'
      "Theory OR Banana Republic OR J.Crew OR Everlane"
    when 'high'
      "Theory OR Vince OR Equipment"
    else
      "" # Let Amazon relevance ranking handle it
    end
  end
end
```

**Amazon Associate Account Requirements**:
1. Sign up at [affiliate-program.amazon.com](https://affiliate-program.amazon.com)
2. Get 3 qualified sales within first 180 days (or account closes)
3. Commission rates: 4% (clothing/accessories), 10% (luxury beauty), 1% (electronics)
4. Payment threshold: $10 minimum (direct deposit or gift card)

**Why Amazon?**
- **Massive inventory**: 90%+ of items users could want
- **Prime shipping**: Users already trust Amazon
- **High conversion**: Familiar checkout = less friction
- **Reliable tracking**: Affiliate links work perfectly
- **Bonus**: You can layer in other affiliates later (Nordstrom 5%, ASOS 8%)

---

#### Component 4: Database Schema

```ruby
# db/migrate/..._create_product_recommendations.rb
class CreateProductRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :product_recommendations do |t|
      t.references :outfit_suggestion, null: false, foreign_key: true

      # Missing item details (from AI detection)
      t.string :category, null: false
      t.text :description
      t.string :color_preference
      t.text :reasoning # Why this item improves the outfit
      t.string :priority # high, medium, low
      t.text :style_notes
      t.string :budget_range # low, mid, high

      # AI-generated product visualization
      t.string :ai_image_url
      t.decimal :ai_image_cost, precision: 8, scale: 4, default: 0.0024

      # Real affiliate products (stored as JSON array)
      t.jsonb :affiliate_products, default: []
      # Example: [{title: "Theory Blazer", price: "$425", affiliate_url: "https://..."}]

      # Analytics
      t.integer :views, default: 0
      t.integer :clicks, default: 0
      t.integer :conversions, default: 0 # Manually updated from Amazon reports
      t.decimal :revenue_earned, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :product_recommendations, :outfit_suggestion_id
    add_index :product_recommendations, :priority
    add_index :product_recommendations, :category
    add_index :product_recommendations, [:views, :clicks] # CTR analysis
  end
end
```

---

### Frontend UI Implementation

**Location**: Add to `app/views/outfit_suggestions/show.html.erb` (after outfit display)

```erb
<% if @outfit_suggestion.product_recommendations.any? %>
  <div class="mt-12 p-8 glass rounded-2xl border border-gradient-purple">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h3 class="text-2xl font-bold text-white flex items-center">
        <svg class="w-7 h-7 mr-3 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
        </svg>
        Complete Your Look
      </h3>
      <span class="text-sm text-gray-400">AI-powered shopping</span>
    </div>

    <p class="text-gray-300 text-sm mb-8">
      These additions would elevate your outfit from good to exceptional:
    </p>

    <!-- Missing Items Loop -->
    <div class="space-y-10">
      <% @outfit_suggestion.product_recommendations.high_priority.each do |rec| %>
        <div class="grid md:grid-cols-[350px_1fr] gap-8 p-6 bg-white/5 rounded-xl border border-white/10 hover:border-purple-500/30 transition">

          <!-- LEFT: AI-Generated Product Visualization -->
          <div class="space-y-4">
            <div class="relative group">
              <%= image_tag rec.ai_image_url,
                class: "w-full h-80 object-cover rounded-lg border border-white/20 shadow-2xl",
                alt: "AI visualization: #{rec.description}",
                data: { action: "click->product#trackView" } %>

              <!-- AI Badge -->
              <div class="absolute top-3 left-3 px-3 py-1.5 bg-purple-600/95 backdrop-blur rounded-lg shadow-lg">
                <span class="text-xs font-bold text-white flex items-center">
                  <svg class="w-3 h-3 mr-1.5" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M13 7H7v6h6V7z"/>
                    <path fill-rule="evenodd" d="M7 2a1 1 0 012 0v1h2V2a1 1 0 112 0v1h2a2 2 0 012 2v2h1a1 1 0 110 2h-1v2h1a1 1 0 110 2h-1v2a2 2 0 01-2 2h-2v1a1 1 0 11-2 0v-1H9v1a1 1 0 11-2 0v-1H5a2 2 0 01-2-2v-2H2a1 1 0 110-2h1V9H2a1 1 0 010-2h1V5a2 2 0 012-2h2V2z" clip-rule="evenodd"/>
                  </svg>
                  AI Generated
                </span>
              </div>
            </div>

            <!-- Description -->
            <div class="space-y-2">
              <p class="text-sm font-medium text-gray-200">
                <%= rec.description %>
              </p>
              <p class="text-xs text-gray-400">
                Suggested for <%= rec.color_preference %> • <%= rec.budget_range.titleize %> range
              </p>
            </div>
          </div>

          <!-- RIGHT: Why + Shop Options -->
          <div class="space-y-6">
            <!-- Why This Works -->
            <div class="p-5 bg-gradient-to-br from-purple-500/10 to-pink-500/10 rounded-lg border border-purple-500/20">
              <h4 class="text-sm font-bold text-purple-300 mb-2 flex items-center">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
                </svg>
                Why this completes your look:
              </h4>
              <p class="text-sm text-gray-300 leading-relaxed">
                <%= rec.reasoning %>
              </p>
            </div>

            <!-- Shop Similar Products -->
            <div class="space-y-4">
              <h4 class="text-base font-bold text-white flex items-center">
                <svg class="w-5 h-5 mr-2 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
                </svg>
                Shop this look:
              </h4>

              <!-- Product Grid -->
              <div class="grid grid-cols-3 gap-4">
                <% rec.affiliate_products.each_with_index do |product, idx| %>
                  <%= link_to track_product_click_path(rec, product_index: idx),
                      target: "_blank",
                      data: {
                        controller: "analytics",
                        action: "click->analytics#trackProductClick",
                        analytics_product_value: product['title']
                      },
                      class: "group block" do %>

                    <!-- Product Card -->
                    <div class="bg-white/5 rounded-lg overflow-hidden border border-white/10 hover:border-purple-500 hover:shadow-lg hover:shadow-purple-500/20 transition-all duration-200">
                      <!-- Product Image -->
                      <div class="relative aspect-square overflow-hidden bg-white">
                        <%= image_tag product['image_url'],
                          class: "w-full h-full object-cover group-hover:scale-105 transition-transform duration-300",
                          loading: "lazy" %>

                        <!-- Prime Badge -->
                        <% if product['prime_eligible'] %>
                          <div class="absolute top-2 right-2 bg-blue-600 text-white text-[10px] font-bold px-2 py-1 rounded shadow-lg">
                            Prime
                          </div>
                        <% end %>
                      </div>

                      <!-- Product Info -->
                      <div class="p-3 space-y-2">
                        <p class="text-xs text-gray-300 line-clamp-2 leading-tight">
                          <%= product['title'].truncate(60) %>
                        </p>

                        <div class="flex items-center justify-between">
                          <span class="text-sm font-bold text-purple-400">
                            <%= product['price'] %>
                          </span>

                          <% if product['rating'] %>
                            <div class="flex items-center text-xs text-yellow-400">
                              <svg class="w-3 h-3 fill-current" viewBox="0 0 20 20">
                                <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                              </svg>
                              <span class="ml-1"><%= product['rating'] %></span>
                            </div>
                          <% end %>
                        </div>

                        <!-- CTA Button -->
                        <button class="w-full mt-2 px-3 py-1.5 bg-gradient-to-r from-purple-600 to-pink-600 text-white text-xs font-medium rounded hover:shadow-lg transition-all">
                          View on Amazon
                        </button>
                      </div>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>

    <!-- Disclosure -->
    <p class="text-xs text-gray-500 mt-8 text-center italic">
      * As an Amazon Associate, we earn from qualifying purchases. This helps us keep the app free for everyone.
    </p>
  </div>
<% end %>
```

---

### Click Tracking & Revenue Attribution

```ruby
# app/controllers/product_recommendations_controller.rb
class ProductRecommendationsController < ApplicationController
  def track_click
    recommendation = ProductRecommendation.find(params[:id])
    product_index = params[:product_index].to_i
    product = recommendation.affiliate_products[product_index]

    # Increment analytics
    recommendation.increment!(:clicks)
    recommendation.increment!(:views) if recommendation.views == 0

    # Track event for analytics
    track_event(
      'product_click',
      user_id: current_user.id,
      recommendation_id: recommendation.id,
      product_title: product['title'],
      product_price: product['price'],
      outfit_context: recommendation.outfit_suggestion.context,
      category: recommendation.category
    )

    # Redirect to Amazon affiliate URL
    redirect_to product['affiliate_url'], allow_other_host: true
  end

  private

  def track_event(name, properties)
    # Send to Mixpanel/Plausible for analytics
    Analytics.track(current_user.id, name, properties)
  end
end
```

**Conversion Tracking**:
- Amazon provides monthly reports via Associate Central dashboard
- Download CSV → import conversions and revenue
- Or use Amazon Product Advertising API reporting endpoint (if available)
- Update `ProductRecommendation#conversions` and `#revenue_earned`

---

### Revenue Projections

#### Conservative (1,000 MAU):
- 1,000 users × 2.5 suggestions/month = 2,500 suggestions
- 2,500 × 30% show shopping = 750 "Complete Your Look" views
- 750 × 8% CTR = 60 clicks
- 60 × 10% conversion = 6 purchases/month
- 6 × $85 AOV × 6% commission = **$30.60/month** = **$367/year**

#### Moderate (5,000 MAU):
- 5,000 × 3 suggestions = 15,000 suggestions
- 15,000 × 35% = 5,250 shopping views
- 5,250 × 10% = 525 clicks
- 525 × 12% = 63 purchases/month
- 63 × $95 AOV × 7% = **$419/month** = **$5,028/year**

#### Scale (20,000 MAU):
- 20,000 × 3.5 suggestions = 70,000 suggestions
- 70,000 × 40% = 28,000 shopping views
- 28,000 × 12% = 3,360 clicks
- 3,360 × 15% = 504 purchases/month
- 504 × $105 AOV × 8% = **$4,234/month** = **$50,808/year**

**Plus AdSense**: $500-2,000/month on free tier pages (dashboard, wardrobe views) = additional revenue layer

---

### Tier Differentiation

**Free Tier**:
- See shopping recommendations with Google AdSense ads
- Standard affiliate links
- Watermarked AI product images

**Premium ($7.99/mo)**:
- Fewer ads in shopping section
- Priority product recommendations (better brands)
- Full-quality AI product images

**Pro ($14.99/mo)**:
- Ad-free shopping experience
- Exclusive brand partnerships (if/when we add them)
- Early access to sales/deals

---

## Phase 5 (NEW): Personalized Avatar Virtual Try-On (Weeks 19-26)

### Goal
Add THE game-changing feature: See missing items on YOUR personalized avatar

### Why This is Revolutionary

**Current State** (Post-Phase 4):
- User sees AI-generated product image of missing blazer
- User sees 3 real products to buy
- **Conversion Hesitation**: "Will it look good on ME?"

**With Avatar Try-On**:
- User uploads 1 photo (one-time setup)
- AI creates personalized 3D avatar matching their body type & skin tone
- **MAGIC MOMENT**: See the suggested blazer ON THEIR AVATAR
- Side-by-side: Current outfit vs. outfit + new blazer
- **Conversion rate 3-5x higher** (industry data from virtual try-on apps)

### User Experience Flow

#### Step 1: Avatar Creation (One-Time Setup)

**Option A: Upload Photo** (Recommended)
```
1. User clicks "Create My Avatar" (prompted after first suggestion)
2. Upload full-body photo (or selfie if full-body not available)
3. AI extracts:
   - Body shape & proportions
   - Skin tone
   - Hair color/style
   - Approximate height from photo metadata
4. Generates personalized 3D avatar (15-30 seconds)
5. User can tweak (adjust height, body type manually if needed)
6. Saved to profile → used for all future try-ons
```

**Option B: Choose Stock Avatar** (Faster, less personalized)
```
1. User sees grid of 20 diverse pre-made avatars
2. Filters: Body type (slim/athletic/curvy/plus), Skin tone, Hair style
3. Select closest match
4. Can customize colors/proportions
5. Instant - no processing time
```

**Why Option A is Better**:
- **Personalization = engagement**: Seeing YOUR avatar creates emotional connection
- **Higher conversion**: "That actually looks like me" → confidence to buy
- **Viral potential**: Users share "Look at my outfit on my avatar!" on social
- **Premium feature**: Free users get Option B, Premium+ get Option A

#### Step 2: Virtual Try-On of Missing Items

**When**: After user sees "Complete Your Look" shopping recommendations

```
1. [Outfit Suggestion Page]
   ├── Your current outfit from wardrobe
   ├── "Complete Your Look" section
   │   ├── AI-generated product image (blazer)
   │   ├── 3 Amazon products to buy
   │   └── 🎁 NEW: "See This On You" button
   │
2. User clicks "See This On You"
   │
3. [Processing Modal - 10-20 seconds]
   ├── "Dressing your avatar..."
   ├── Progress bar animation
   │
4. [Virtual Try-On Result]
   ├── Side-by-side comparison:
   │   ├── LEFT: Current outfit (without blazer)
   │   └── RIGHT: Complete outfit (WITH blazer)
   │
   ├── User controls:
   │   ├── Rotate avatar (360° view)
   │   ├── Zoom in/out
   │   ├── Change pose (standing, sitting, walking)
   │
   └── CTA: "Love it? Shop Now" → Links to Amazon products
```

### Technical Deep Dive

#### Avatar Generation Tech Stack

**Approach 1: ControlNet + Stable Diffusion (Recommended for MVP)**

**What is ControlNet?**
> ControlNet is an AI model extension that lets you control image generation with "pose guides". Think of it as:
> - You provide: A photo of a person
> - ControlNet extracts: Body pose, proportions, shape
> - Then generates: New images in that EXACT pose with different clothes
>
> **Example**: Take your selfie → ControlNet learns your pose → generates you wearing a blazer in the same pose

**Implementation**:
```ruby
# app/services/avatar_creation_service.rb
class AvatarCreationService
  def create_from_photo(user_photo_path)
    # Step 1: Extract pose skeleton using ControlNet preprocessor
    pose_map = extract_pose(user_photo_path)

    # Step 2: Extract body measurements & skin tone
    body_analysis = analyze_body_features(user_photo_path)

    # Step 3: Generate clean avatar using Stable Diffusion + ControlNet
    avatar_image = generate_avatar(
      pose_map: pose_map,
      body_type: body_analysis[:body_type],
      skin_tone: body_analysis[:skin_tone],
      hair_color: body_analysis[:hair_color]
    )

    # Step 4: Save avatar to user profile
    user.update!(
      avatar_url: upload_to_cloud(avatar_image),
      avatar_metadata: body_analysis
    )
  end

  private

  def extract_pose(photo_path)
    # Use ControlNet OpenPose preprocessor
    # Returns: JSON skeleton of body landmarks (shoulders, elbows, hips, etc.)
    HTTParty.post(
      "https://api.replicate.com/v1/predictions",
      body: {
        version: "controlnet-openpose-preprocessor",
        input: { image: photo_path }
      }.to_json
    )
  end

  def analyze_body_features(photo_path)
    # Use Gemini Vision to extract features
    prompt = <<~PROMPT
      Analyze this person and return JSON:
      {
        "body_type": "athletic" | "slim" | "curvy" | "plus_size",
        "skin_tone": "light" | "medium" | "tan" | "deep",
        "hair_color": "blonde" | "brown" | "black" | "red" | "gray",
        "estimated_height": "short" | "average" | "tall"
      }
    PROMPT

    ImageAnalysisService.new.analyze_with_prompt(photo_path, prompt)
  end

  def generate_avatar(pose_map:, body_type:, skin_tone:, hair_color:)
    # Generate clean avatar using SDXL + ControlNet
    prompt = <<~PROMPT
      Full body portrait, standing pose, facing forward.
      #{body_type} build, #{skin_tone} skin, #{hair_color} hair.
      Wearing neutral gray t-shirt and jeans.
      Clean white studio background, professional lighting.
      High quality, photorealistic, 8K.
    PROMPT

    HTTParty.post(
      "https://api.replicate.com/v1/predictions",
      body: {
        version: "stability-ai/sdxl + controlnet",
        input: {
          prompt: prompt,
          control_image: pose_map,
          controlnet_conditioning_scale: 0.8
        }
      }.to_json
    )
  end
end
```

**Cost**: $0.04-0.06 per avatar creation (one-time per user)

---

**Approach 2: VITON-HD (Virtual Try-On Specialized Model)**

**What is VITON-HD?**
> VITON-HD is a specialized AI model built specifically for "dressing" people in clothes.
> - Input: Person photo + garment photo
> - Output: Person wearing that exact garment
> - Preserves: Body shape, pose, skin tone
> - Changes: Only the clothing
>
> **Example**: Your avatar photo + blazer photo → Your avatar wearing that blazer

**Why VITON-HD is Better for Try-On (but harder to implement)**:
- Purpose-built for fashion (vs. general image generation)
- Better fabric rendering (wrinkles, texture, fit)
- Faster processing (~5 seconds vs. 15-20 for ControlNet)
- BUT: Harder to self-host, requires GPUs

**Implementation**:
```ruby
# app/services/virtual_tryon_service.rb
class VirtualTryonService
  def dress_avatar(avatar_url, garment_image_url)
    # Use VITON-HD via Replicate or custom deployment
    response = HTTParty.post(
      "https://api.replicate.com/v1/predictions",
      body: {
        version: "viton-hd-model-id",
        input: {
          person_image: avatar_url,
          garment_image: garment_image_url,
          category: "upper_body" # or "lower_body", "dress"
        }
      }.to_json
    )

    # Returns: Avatar wearing the garment
    poll_for_result(response['urls']['get'])
  end
end
```

**Cost**: $0.08-0.12 per try-on render

**Why Cost is High**:
- Complex AI processing (2 images → 1 composite)
- GPU-intensive (requires NVIDIA A100 or better)
- Longer processing time (10-20 seconds)

**Mitigation Strategies**:
1. **Limit to Pro tier**: 15 try-ons/month ($14.99 price supports cost)
2. **Cache results**: If user tries same blazer twice, show cached version
3. **Batch processing**: Queue requests, process in batches to optimize GPU usage
4. **Self-host at scale**: If >10,000 renders/month, deploy own VITON-HD instance

---

#### Recommended Implementation Path

**MVP (Phase 5 Week 1-3): Stock Avatars + ControlNet**
```
1. Create 20 diverse stock avatars (body types, skin tones)
2. User picks closest match
3. Use ControlNet to generate outfit combinations
4. Simple, fast, low cost ($0.04/render)
```

**V2 (Phase 5 Week 4-6): Photo Upload → Custom Avatar**
```
1. Add "Upload Your Photo" feature
2. Extract pose + features
3. Generate personalized avatar
4. Still use ControlNet for try-on
5. Medium cost ($0.06/render)
```

**V3 (Post-Phase 5): VITON-HD for Pro Tier**
```
1. Integrate VITON-HD for photorealistic try-on
2. Pro users get 15 VITON-HD renders/month
3. Premium users still use ControlNet
4. High quality, higher cost justifies Pro pricing
```

---

### Revenue Impact

**Conversion Rate Boost**:
- **Current** (just product recommendations): 10-12% purchase rate
- **With avatar try-on**: 30-40% purchase rate (3-4x increase)

**Why Such a Big Jump?**
- Removes "fit anxiety" ("Will it look good on me?")
- Emotional engagement (seeing yourself → ownership mindset)
- Social proof (share avatar outfit → friends buy too)

**New Revenue Math (20,000 MAU with avatar)**:
- 70,000 suggestions × 40% shopping = 28,000 views
- 28,000 × 12% CTR = 3,360 clicks
- 3,360 × **35% conversion** (vs. 15% without avatar) = 1,176 purchases/month
- 1,176 × $105 AOV × 8% = **$9,878/month** = **$118,536/year**

**That's 2.3x the revenue from Phase 4 alone!**

---

### Cost Analysis

**Avatar Creation** (One-Time):
- Stock avatar selection: $0 (pre-made)
- Photo upload → custom avatar: $0.04-0.06 per user

**Try-On Rendering** (Per Use):
- ControlNet approach: $0.04-0.06 per render
- VITON-HD approach: $0.08-0.12 per render

**Monthly Cost at Scale**:
- 20,000 users × 10% use avatars = 2,000 active avatar users
- 2,000 × 3 try-ons/month = 6,000 renders/month
- 6,000 × $0.05 avg = **$300/month cost**

**Gross Profit**:
- Affiliate revenue from avatars: $9,878/month
- Avatar costs: -$300/month
- **Net profit: $9,578/month** from this feature alone

**Plus**: Pro tier at $14.99/mo can include 15 try-ons → more direct revenue

---

### Tier Differentiation

**Free Tier**:
- Choose from 10 basic stock avatars
- 1 try-on per week
- Watermarked results

**Premium ($7.99/mo)**:
- Upload photo → custom avatar
- 10 try-ons per month
- Full-quality exports
- Share to social (no watermark)

**Pro ($14.99/mo)**:
- Upload photo → custom avatar with pose options
- 30 try-ons per month (or unlimited with ControlNet, limited VITON-HD)
- 360° avatar rotation
- Multiple poses (standing, sitting, walking)
- Priority processing (faster renders)
- Download avatar outfits as high-res images

---

## Clarifying Your Questions

### Q1: "Upload photo or choose from existing avatars?"

**Answer: BOTH - Progressive Enhancement**

**Phase 5A (Weeks 19-20)**: Stock Avatars Only
- Launch with 20 diverse pre-made avatars
- Users pick closest match (body type, skin tone, hair)
- Instant - no processing time
- Low cost - no API calls needed
- Get feedback on feature usefulness

**Phase 5B (Weeks 21-22)**: Add Photo Upload
- Premium/Pro users can upload their photo
- AI generates personalized avatar
- Free users still use stock avatars (upgrade incentive)
- Test conversion rate impact

**Why This Approach?**
- **Ship faster**: Don't block launch on photo upload complexity
- **Validate demand**: See if users even want virtual try-on before investing heavily
- **Freemium upsell**: "Upload YOUR photo" becomes Premium feature

---

### Q2: "Virtual Dressing - what does this mean?"

**Simple Explanation**:

**Stable Diffusion Inpainting**:
> Think of it like Photoshop's "Content-Aware Fill" but powered by AI.
>
> **How it works**:
> 1. Start with: Avatar wearing plain gray t-shirt
> 2. You "mask" (select) the t-shirt area
> 3. Tell AI: "Replace this with a navy blazer"
> 4. AI "paints in" the blazer, matching lighting/shadows/fit
>
> **Result**: Same avatar, same pose, new clothing

**VITON-HD (Virtual Try-On Network)**:
> A specialized AI model trained on 100,000s of fashion photos specifically for clothing changes.
>
> **How it works**:
> 1. Input A: Photo of person
> 2. Input B: Photo of garment (blazer)
> 3. AI analyzes:
>    - Person's body shape, pose, lighting
>    - Garment's texture, fit, drape
> 4. AI generates: Person wearing that specific garment
>    - Preserves person's pose/body
>    - Realistic fabric wrinkles, shadows
>    - Accurate fit (loose/tight/tailored)
>
> **Result**: Looks like a real product photo of that person wearing that item

**Which to Use?**
- **ControlNet + SDXL**: Easier to implement, good quality, cheaper ($0.04)
- **VITON-HD**: Best quality, photorealistic, more expensive ($0.10)

**Recommendation**: Start with ControlNet for MVP, upgrade to VITON-HD for Pro tier later

---

### Q3: "Cost ~$0.10 per try-on render - that's huge!"

**Why I Quoted $0.10**:
- That was for VITON-HD (highest quality)
- Includes GPU processing costs + API markup

**Actual Costs Breakdown**:

**Option 1: ControlNet + SDXL (Recommended for MVP)**
- Processing: $0.024 (Replicate SDXL pricing)
- ControlNet preprocessing: $0.008
- API overhead: $0.008
- **Total: ~$0.04 per render**

**Option 2: VITON-HD (Pro tier later)**
- Processing: $0.06 (specialized model)
- API overhead: $0.02
- **Total: ~$0.08-0.10 per render**

**Option 3: Self-Hosted (At 100k+ renders/month)**
- GPU rental (NVIDIA A100): $2.50/hour
- Can process 100 renders/hour
- **Total: ~$0.025 per render**
- BUT: Requires DevOps expertise + monitoring

**Is $0.04-0.10 "Huge"?**

**Let's Compare to Revenue**:
- User sees outfit suggestion
- Clicks "See This On You" → costs you $0.04
- They buy a $120 blazer → you earn $9.60 (8% commission)
- **ROI: 240x return on that $0.04 investment**

**Even if only 5% of try-ons convert**:
- 100 try-ons × $0.04 = $4 cost
- 5 purchases × $100 × 8% = $40 revenue
- **Profit: $36 (10x ROI)**

**Mitigation Strategies**:
1. **Limit free tier**: 1 try-on/week (prevents abuse)
2. **Premium tier**: 10/month (most users won't hit limit)
3. **Pro tier**: 30/month (power users, but they pay $14.99)
4. **Cache results**: Same avatar + same blazer = cached image (instant, $0 cost)

---

### Q4: "Google AdSense $500-2,000/month - explain?"

**What is Google AdSense?**
> Display ads on your website. You get paid when users:
> - View ads (CPM - Cost Per Thousand Impressions)
> - Click ads (CPC - Cost Per Click)
>
> **Example**: User browsing wardrobe → sees banner ad for Amazon Prime → you earn $0.50

**Where to Place Ads** (Without Ruining UX):

1. **Dashboard page** (free tier only)
   - Small banner between sections
   - "Recommended for you" native ads

2. **Wardrobe items list** (free tier only)
   - Sidebar ads (fashion-related)
   - Between item rows (every 20 items)

3. **After AI suggestions** (free tier only)
   - "While you're here..." ad placement
   - Fashion/shopping related ads (higher CPM)

**Revenue Math**:

**Conservative** (5,000 free tier users):
- 5,000 users × 10 pageviews/month = 50,000 pageviews
- 50,000 × $4 RPM (Revenue Per Mille) = **$200/month**

**Moderate** (15,000 free tier users):
- 15,000 × 12 pageviews = 180,000 pageviews
- 180,000 × $5 RPM = **$900/month**

**Optimistic** (30,000 free tier users, fashion-optimized):
- 30,000 × 15 pageviews = 450,000 pageviews
- 450,000 × $8 RPM (fashion CPM is high) = **$3,600/month**

**Why RPM Varies**:
- Fashion = high-value niche ($6-10 RPM vs. $2-3 for blogs)
- Your users are shopping-ready (premium CPM)
- Geographic location (US/UK = higher, global = lower)

**Tier Strategy**:
- **Free tier**: Show ads (helps offset server costs)
- **Premium tier**: Reduced ads (incentive to upgrade)
- **Pro tier**: Zero ads (premium experience)

**Why This is "Supplemental"**:
- Not core revenue (that's subscriptions + affiliate)
- But nice bonus: $500-2k/month pays for hosting + AI costs
- Ethical placement: Only show relevant fashion/shopping ads

---

## Updated Revenue Projections Summary

| Phase | Timeline | MRR | Revenue Sources | Notes |
|-------|----------|-----|-----------------|-------|
| Phase 3 | Week 12 | $1,000 | Subscriptions | Premium launch |
| Phase 4 | Week 18 | $2,500 | Subs + Affiliate + Ads | Shopping feature |
| Phase 5 | Week 26 | $8,000 | Subs + Affiliate (3x) + Ads | Avatar try-on |
| Month 9 | Week 36 | $15,000 | All sources at scale | $10k goal exceeded |

**Phase 4 Impact** (Shopping + Affiliate):
- Affiliate revenue: $400-600/month initially
- AdSense: $200-500/month
- **Total new revenue: $600-1,100/month**

**Phase 5 Impact** (Avatar Try-On):
- Affiliate revenue: 3x increase (due to higher conversion)
- Pro tier upgrades: 15-20% of Premium users
- **Total new revenue: $5,000-6,000/month**

---

## Final Tech Stack Summary

### Core Application
- **Framework**: Rails 7.1 + Hotwire (Turbo/Stimulus)
- **Frontend**: Tailwind CSS v4
- **Database**: PostgreSQL + pgvector (embeddings)
- **Hosting**: Railway/Heroku ($50-100/month)

### AI Services
- **Outfit Suggestions**: Vertex AI Gemini 2.5 Flash ($0.001/request)
- **Missing Item Detection**: Gemini 2.5 Flash ($0.0015/request)
- **Product Image Generation**: Replicate SDXL ($0.0024/image)
- **Avatar Creation**: Replicate ControlNet + SDXL ($0.04-0.06/avatar)
- **Virtual Try-On**: ControlNet ($0.04/render) → VITON-HD later ($0.10/render)

### Third-Party APIs
- **Affiliate**: Amazon Product Advertising API (free, 4-10% commission)
- **Payments**: Stripe (2.9% + $0.30/transaction)
- **Ads**: Google AdSense (free to join, $4-10 RPM)
- **Image Storage**: AWS S3/Cloudflare R2 ($5-20/month)

---

## Next Immediate Steps

1. **Commit presentation_style changes** ✓
2. **Test AI suggestions** with 77 seeded items
3. **Plan Phase 4 kickoff**:
   - Sign up for Amazon Associates account
   - Set up Replicate API account
   - Design "Complete Your Look" UI mockups
4. **Update PROJECT_STATUS.md** with this new roadmap

**Ready to proceed?** What should we tackle first?
