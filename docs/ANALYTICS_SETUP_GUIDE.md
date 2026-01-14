# Analytics Setup Guide

This guide will walk you through setting up metrics tracking from scratch.

---

## Part 1: Set Up Plausible Analytics (30 minutes)

**Why Plausible over Google Analytics?**
- Privacy-friendly (GDPR compliant, no cookie banner needed)
- Simple, fast dashboard
- €9/month (free 30-day trial)
- Perfect for startups

### Step-by-Step Setup:

**Step 1: Create Account**
1. Go to https://plausible.io
2. Click "Start your free trial"
3. Enter email: your@email.com
4. Choose plan: "Growth" (€9/mo, 10k pageviews)
5. Add domain: `outfitmaker.ai`

**Step 2: Install Tracking Code**
1. Plausible will give you a script tag like this:
```html
<script defer data-domain="outfitmaker.ai" src="https://plausible.io/js/script.js"></script>
```

2. Add it to your Rails layout file:

**File:** `app/views/layouts/application.html.erb`

Find the `<head>` section and add:

```erb
<head>
  <title>OutfitMaker.ai - AI Wardrobe Stylist</title>
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>

  <!-- Plausible Analytics -->
  <% unless Rails.env.development? %>
    <script defer data-domain="outfitmaker.ai" src="https://plausible.io/js/script.js"></script>
  <% end %>
</head>
```

**Note:** The `unless Rails.env.development?` prevents tracking yourself during development.

**Step 3: Test It Works**
1. Deploy your app (or test on production if already deployed)
2. Visit your site in incognito mode
3. Go to Plausible dashboard: https://plausible.io/outfitmaker.ai
4. You should see 1 visitor (you!)

---

## Part 2: Track Custom Events (60 minutes)

Plausible can track specific user actions. Here's how to track key events.

### Events to Track:

1. **Signup** - User creates account
2. **Activation** - User uploads 5th wardrobe item
3. **Engagement** - User requests outfit suggestion
4. **Trial Start** - User starts paid trial
5. **Conversion** - User becomes paying customer
6. **Affiliate Click** - User clicks "Complete Your Look" product

### Implementation:

**Step 1: Add Plausible Custom Events Script**

In your layout, change the Plausible script to:

```erb
<!-- Plausible Analytics with Custom Events -->
<% unless Rails.env.development? %>
  <script defer data-domain="outfitmaker.ai" src="https://plausible.io/js/script.tagged-events.js"></script>
  <script>
    window.plausible = window.plausible || function() { (window.plausible.q = window.plausible.q || []).push(arguments) }
  </script>
<% end %>
```

**Step 2: Track Signup Event**

**File:** `app/controllers/users/registrations_controller.rb`

```ruby
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # Track signup event in Plausible
        # (This will be sent from client-side via Stimulus)
      end
    end
  end
end
```

**File:** `app/views/devise/registrations/new.html.erb`

Add this after successful signup (use Turbo Stream or Stimulus):

```erb
<script>
  // Track signup event after form submission succeeds
  document.addEventListener('turbo:submit-end', function(event) {
    if (event.detail.success) {
      if (typeof plausible !== 'undefined') {
        plausible('Signup');
      }
    }
  });
</script>
```

**Step 3: Track Activation (5th Item Upload)**

**File:** `app/controllers/wardrobe_items_controller.rb`

```ruby
def create
  @wardrobe_item = current_user.wardrobe_items.build(wardrobe_item_params)

  if @wardrobe_item.save
    # Check if this is the 5th item (activation!)
    if current_user.wardrobe_items.count == 5
      # Trigger activation event via Turbo Stream
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append("wardrobe_items", partial: "wardrobe_items/wardrobe_item", locals: { wardrobe_item: @wardrobe_item }),
            turbo_stream.append("body", "<script>if(typeof plausible !== 'undefined'){plausible('Activation')}</script>")
          ]
        }
      end
    else
      # Normal response
      respond_to do |format|
        format.turbo_stream
      end
    end
  end
end
```

**Step 4: Track Outfit Suggestion Request**

**File:** `app/javascript/controllers/outfit_suggestion_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Listen for successful outfit generation
    this.element.addEventListener('turbo:submit-end', (event) => {
      if (event.detail.success) {
        // Track engagement event
        if (typeof window.plausible !== 'undefined') {
          window.plausible('Outfit Suggestion');
        }
      }
    });
  }
}
```

**Step 5: Track Affiliate Clicks**

**File:** `app/views/product_recommendations/_affiliate_product.html.erb`

```erb
<%= link_to track_product_click_path(recommendation, product_index: idx),
    target: "_blank",
    data: {
      controller: "analytics",
      action: "click->analytics#trackProductClick",
      analytics_product_value: product['title']
    },
    class: "group block" do %>
  <!-- Product card content -->
<% end %>
```

**File:** `app/javascript/controllers/analytics_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  trackProductClick(event) {
    // Track affiliate click
    if (typeof window.plausible !== 'undefined') {
      window.plausible('Affiliate Click', {
        props: { product: this.element.dataset.analyticsProductValue }
      });
    }
  }
}
```

**Step 6: Track Trial Start & Conversion**

**File:** `app/controllers/subscriptions_controller.rb`

```ruby
def create
  # After successful Stripe checkout
  if subscription_created
    # Track trial start
    render turbo_stream: turbo_stream.append("body",
      "<script>if(typeof plausible !== 'undefined'){plausible('Trial Start')}</script>"
    )
  end
end

def activate
  # When trial converts to paid (webhook from Stripe)
  if subscription.status == 'active'
    # Track conversion (this happens server-side, so use Plausible API)
    PlausibleService.track_event(user_id: subscription.user_id, event: 'Conversion')
  end
end
```

---

## Part 3: Set Up UTM Tracking (15 minutes)

UTM parameters let you track where traffic comes from.

### UTM Parameter Format:

```
https://outfitmaker.ai?utm_source=producthunt&utm_medium=launch&utm_campaign=feb2026
```

**Parameters:**
- `utm_source` = Where traffic comes from (producthunt, reddit, twitter)
- `utm_medium` = Type of traffic (social, email, ads)
- `utm_campaign` = Specific campaign (feb2026_launch, beta_invite)

### Create UTM Links for Launch:

**Product Hunt:**
```
https://outfitmaker.ai?utm_source=producthunt&utm_medium=social&utm_campaign=launch
```

**Reddit (r/femalefashionadvice):**
```
https://outfitmaker.ai?utm_source=reddit_ffa&utm_medium=social&utm_campaign=launch
```

**Beta Tester Invites:**
```
https://outfitmaker.ai/beta?utm_source=email&utm_medium=beta_invite&utm_campaign=beta
```

**Use a UTM Builder:** https://ga-dev-tools.google/ga4/campaign-url-builder/

Plausible will automatically track these and show you traffic sources.

---

## Part 4: Set Up Google Sheets Dashboard (30 minutes)

### Step 1: Create New Google Sheet

1. Go to https://sheets.google.com
2. Create new spreadsheet: "OutfitMaker.ai Metrics"
3. Import the CSV template from `docs/METRICS_TRACKING_TEMPLATE.csv`

### Step 2: Set Up Formulas

**Tab 1: Acquisition Funnel**

In cell C7 (Signup Rate formula):
```
=IF(B7=0, "0%", TEXT(C7/B7, "0.0%"))
```

Copy this formula pattern for:
- Activation Rate (column F)
- Trial Rate (column H)
- Conversion Rate (column J)

**Tab 2: Retention Cohorts**

In cell D3 (Day 1 % formula):
```
=IF(B3=0, "0%", TEXT(C3/B3, "0.0%"))
```

Copy across for Day 7%, Day 30%, Day 90%.

**Tab 5: Dashboard Summary**

In cell D3 (Status indicator):
```
=IF(B3=0, "🔴 0%", IF(B3/C3 < 0.5, "🔴 " & TEXT(B3/C3, "0%"), IF(B3/C3 < 0.8, "🟡 " & TEXT(B3/C3, "0%"), "🟢 " & TEXT(B3/C3, "0%"))))
```

This shows:
- 🔴 Red if <50% of target
- 🟡 Yellow if 50-80% of target
- 🟢 Green if >80% of target

### Step 3: Manual Data Entry Schedule

**Daily (5 minutes):**
- Check Plausible dashboard
- Update Tab 1 (Acquisition) with yesterday's numbers

**Weekly (15 minutes on Monday):**
- Update Tab 2 (Retention Cohorts)
- Calculate how many Week 1 signups returned on Day 7

**Monthly (30 minutes on 1st of month):**
- Update Tab 3 (Monetization)
- Get MRR from Stripe dashboard
- Calculate affiliate revenue from Amazon Associates
- Update Tab 4 (Churn) with canceled subscriptions

### Step 4: Automate with Zapier (Optional, Later)

Once you have 100+ users, manual tracking becomes tedious. Use Zapier to auto-populate:

- Plausible → Google Sheets (daily summary)
- Stripe → Google Sheets (new subscriptions, churn)
- Requires Zapier Pro ($20/mo, only worth it at scale)

---

## Part 5: Database Queries for Metrics (15 minutes)

You'll need to run Rails console queries to get some metrics.

### Key Queries:

**Total Users (This Week):**
```ruby
User.where("created_at >= ?", 1.week.ago).count
```

**Activation Rate (Users with 5+ Items):**
```ruby
total_users = User.count
activated_users = User.joins(:wardrobe_items)
  .group("users.id")
  .having("COUNT(wardrobe_items.id) >= 5")
  .count
  .size

activation_rate = (activated_users.to_f / total_users * 100).round(1)
puts "Activation Rate: #{activation_rate}%"
```

**Day 7 Retention:**
```ruby
week_ago_signups = User.where("created_at >= ? AND created_at < ?", 14.days.ago, 7.days.ago)
returned_day_7 = week_ago_signups.select do |user|
  user.last_sign_in_at && user.last_sign_in_at > user.created_at + 6.days
end

retention_rate = (returned_day_7.size.to_f / week_ago_signups.size * 100).round(1)
puts "Day 7 Retention: #{retention_rate}%"
```

**Monthly Churn (Paid Users):**
```ruby
# Assuming you have a subscriptions table
month_start_paid = Subscription.where(status: 'active').where("created_at < ?", 1.month.ago).count
churned_this_month = Subscription.where(status: 'canceled').where("canceled_at >= ?", 1.month.ago).count

churn_rate = (churned_this_month.to_f / month_start_paid * 100).round(1)
puts "Monthly Churn: #{churn_rate}%"
```

**Save these as Rake tasks for easy access:**

**File:** `lib/tasks/metrics.rake`

```ruby
namespace :metrics do
  desc "Calculate key metrics"
  task summary: :environment do
    puts "\n=== OutfitMaker.ai Metrics Summary ==="
    puts "Date: #{Date.today}"

    total_users = User.count
    puts "\n📊 Total Users: #{total_users}"

    activated = User.joins(:wardrobe_items)
      .group("users.id")
      .having("COUNT(wardrobe_items.id) >= 5")
      .count
      .size
    activation_rate = total_users > 0 ? (activated.to_f / total_users * 100).round(1) : 0
    puts "✅ Activated (5+ items): #{activated} (#{activation_rate}%)"

    paid_users = User.where(subscription_tier: ['premium', 'pro']).count
    conversion_rate = total_users > 0 ? (paid_users.to_f / total_users * 100).round(1) : 0
    puts "💰 Paid Users: #{paid_users} (#{conversion_rate}%)"

    # Calculate MRR
    premium_count = User.where(subscription_tier: 'premium').count
    pro_count = User.where(subscription_tier: 'pro').count
    mrr = (premium_count * 7.99) + (pro_count * 14.99)
    puts "💵 MRR: €#{mrr.round(2)}"

    puts "\n" + "="*50 + "\n"
  end
end
```

**Run with:** `rails metrics:summary`

---

## Testing Your Setup

### Checklist:

- [ ] Plausible shows live visitors
- [ ] Custom events appear in Plausible dashboard
- [ ] UTM parameters tracked correctly
- [ ] Google Sheets formulas calculate correctly
- [ ] Rails console queries return data
- [ ] `rails metrics:summary` works

### Test Script:

1. **Test Plausible:** Visit site in incognito, check dashboard
2. **Test Signup Event:** Create dummy account, check Plausible events
3. **Test UTM:** Visit `outfitmaker.ai?utm_source=test`, check Plausible sources
4. **Test Spreadsheet:** Add fake data, verify formulas calculate
5. **Test Rails Query:** Run `rails metrics:summary` in console

---

## Troubleshooting

**Plausible not tracking:**
- Check script is in `<head>` section
- Verify you're testing on production domain (not localhost)
- Check browser console for errors

**Custom events not firing:**
- Verify `script.tagged-events.js` is loaded
- Check browser console: `typeof plausible` should return "function"
- Add `console.log('Event fired!')` before `plausible()` call

**UTM parameters not showing:**
- Wait 24 hours (Plausible updates daily)
- Check you're using correct URL format
- Verify parameters aren't stripped by redirects

---

## Next Steps

Once tracking is working:
1. Monitor for 1 week (get baseline data)
2. Start beta launch (Week 3)
3. Check metrics daily
4. Adjust strategy based on data

---

**Questions?** Review this guide and test each section. Let me know if you get stuck!