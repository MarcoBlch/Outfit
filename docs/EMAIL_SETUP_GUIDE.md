# Email Setup Guide (Mailgun + Rails)

Complete step-by-step guide to set up transactional emails for OutfitMaker.ai.

---

## Why Mailgun?

- **Reliable:** 99.99% uptime
- **Affordable:** 1,000 emails/month free, then €0.80 per 1,000
- **Developer-friendly:** Great Rails integration
- **Deliverability:** High inbox rate (emails don't go to spam)

---

## Part 1: Create Mailgun Account (15 minutes)

### Step 1: Sign Up

1. Go to https://www.mailgun.com
2. Click "Start Sending"
3. Create account with your email
4. **Choose EU region** (GDPR compliance)
5. Verify your email address

### Step 2: Add Your Domain

1. In Mailgun dashboard, click "Sending" → "Domains"
2. Click "Add New Domain"
3. Enter: `mg.outfitmaker.ai` (subdomain for emails)
4. Click "Add Domain"

**Why subdomain?** This keeps your main domain reputation safe. If emails bounce, it doesn't affect `outfitmaker.ai`.

### Step 3: Verify Domain (DNS Setup)

Mailgun will show you DNS records to add. You need to add these to your DNS provider (Railway, Cloudflare, etc.).

**Required DNS Records:**

**TXT Record (SPF):**
```
Hostname: mg.outfitmaker.ai
Type: TXT
Value: v=spf1 include:mailgun.org ~all
```

**TXT Record (DKIM):**
```
Hostname: mailo._domainkey.mg.outfitmaker.ai
Type: TXT
Value: [Long string provided by Mailgun]
```

**CNAME Record (Tracking):**
```
Hostname: email.mg.outfitmaker.ai
Type: CNAME
Value: mailgun.org
```

**MX Records (Receiving):**
```
Hostname: mg.outfitmaker.ai
Type: MX
Priority: 10
Value: mxa.mailgun.org

Hostname: mg.outfitmaker.ai
Type: MX
Priority: 10
Value: mxb.mailgun.org
```

### Step 4: Get API Keys

1. In Mailgun dashboard, go to "Settings" → "API Keys"
2. Copy your **Private API Key** (starts with `key-...`)
3. Save it somewhere safe (you'll need it for Rails config)

---

## Part 2: Configure Rails (30 minutes)

### Step 1: Add Mailgun Gem

**File:** `Gemfile`

```ruby
# Email delivery
gem 'mailgun-ruby', '~> 1.2'
```

Run:
```bash
bundle install
```

### Step 2: Configure Action Mailer

**File:** `config/environments/production.rb`

```ruby
Rails.application.configure do
  # ... existing config ...

  # Email configuration (Mailgun)
  config.action_mailer.delivery_method = :mailgun
  config.action_mailer.mailgun_settings = {
    api_key: ENV['MAILGUN_API_KEY'],
    domain: ENV['MAILGUN_DOMAIN']
  }

  config.action_mailer.default_url_options = { host: 'outfitmaker.ai', protocol: 'https' }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
end
```

**File:** `config/environments/development.rb`

```ruby
Rails.application.configure do
  # ... existing config ...

  # In development, just log emails (don't actually send)
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
end
```

### Step 3: Add Environment Variables

**File:** `.env` (create if doesn't exist)

```bash
# Mailgun Configuration
MAILGUN_API_KEY=key-your_actual_api_key_here
MAILGUN_DOMAIN=mg.outfitmaker.ai
```

**Important:** Add `.env` to `.gitignore` so you don't commit secrets!

**File:** `.gitignore`

```
# Environment variables
.env
.env.local
```

### Step 4: Configure Mailgun Initializer

**File:** `config/initializers/mailgun.rb`

```ruby
require 'mailgun-ruby'

# Configure Mailgun
Mailgun.configure do |config|
  config.api_key = ENV['MAILGUN_API_KEY']
  config.domain = ENV['MAILGUN_DOMAIN']
  config.api_host = 'api.eu.mailgun.net' # EU region (GDPR)
end

# Custom delivery method for Action Mailer
ActionMailer::Base.add_delivery_method :mailgun, Mail::Mailgun, {
  api_key: ENV['MAILGUN_API_KEY'],
  domain: ENV['MAILGUN_DOMAIN'],
  api_host: 'api.eu.mailgun.net'
}
```

---

## Part 3: Create Email Templates (45 minutes)

### Step 1: Generate Mailer

```bash
rails generate mailer UserMailer welcome activation_reminder trial_ending
```

This creates:
- `app/mailers/user_mailer.rb`
- `app/views/user_mailer/welcome.html.erb`
- `app/views/user_mailer/welcome.text.erb`

### Step 2: Configure UserMailer

**File:** `app/mailers/user_mailer.rb`

```ruby
class UserMailer < ApplicationMailer
  default from: 'OutfitMaker.ai <hello@mg.outfitmaker.ai>'
  layout 'mailer'

  # Welcome email (sent immediately after signup)
  def welcome(user)
    @user = user
    @app_url = "https://outfitmaker.ai"

    mail(
      to: email_address_with_name(@user.email, @user.username),
      subject: "Welcome to OutfitMaker.ai! Here's how to get started"
    )
  end

  # Activation reminder (sent 24 hours after signup if <5 items uploaded)
  def activation_reminder(user)
    @user = user
    @items_count = user.wardrobe_items.count
    @items_needed = [5 - @items_count, 0].max

    mail(
      to: @user.email,
      subject: "You're #{@items_needed} items away from your first AI outfit!"
    )
  end

  # Trial ending reminder (sent 2 days before trial ends)
  def trial_ending(user)
    @user = user
    @trial_end_date = user.trial_ends_at.strftime("%B %d, %Y")

    mail(
      to: @user.email,
      subject: "Your trial ends in 2 days - 50% off inside!"
    )
  end
end
```

### Step 3: Create Email Templates

**File:** `app/views/user_mailer/welcome.html.erb`

```erb
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #374151;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background: linear-gradient(135deg, #9333ea 0%, #ec4899 100%);
      padding: 30px;
      text-align: center;
      border-radius: 8px 8px 0 0;
    }
    .header h1 {
      color: white;
      margin: 0;
      font-size: 24px;
    }
    .content {
      background: white;
      padding: 30px;
      border: 1px solid #e5e7eb;
      border-top: none;
      border-radius: 0 0 8px 8px;
    }
    .button {
      display: inline-block;
      background: linear-gradient(135deg, #9333ea 0%, #ec4899 100%);
      color: white;
      padding: 14px 28px;
      text-decoration: none;
      border-radius: 6px;
      font-weight: 600;
      margin: 20px 0;
    }
    .steps {
      background: #f9fafb;
      padding: 20px;
      border-radius: 6px;
      margin: 20px 0;
    }
    .step {
      margin: 15px 0;
    }
    .step-number {
      display: inline-block;
      background: #9333ea;
      color: white;
      width: 28px;
      height: 28px;
      line-height: 28px;
      text-align: center;
      border-radius: 50%;
      font-weight: bold;
      margin-right: 10px;
    }
    .footer {
      text-align: center;
      color: #9ca3af;
      font-size: 14px;
      margin-top: 30px;
      padding-top: 20px;
      border-top: 1px solid #e5e7eb;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Welcome to OutfitMaker.ai! 👋</h1>
  </div>

  <div class="content">
    <p>Hi <%= @user.username %>,</p>

    <p>Thanks for signing up! You're about to discover how AI can transform your wardrobe from <em>"I have nothing to wear"</em> to <em>"I have so many options!"</em></p>

    <div class="steps">
      <h3 style="margin-top: 0;">Here's what to do first:</h3>

      <div class="step">
        <span class="step-number">1</span>
        <strong>Upload your wardrobe</strong> (10-15 items is a great start)<br>
        <span style="color: #6b7280; font-size: 14px;">📸 Tip: Take photos in good lighting. No need for perfection!</span>
      </div>

      <div class="step">
        <span class="step-number">2</span>
        <strong>Request your first outfit</strong><br>
        <span style="color: #6b7280; font-size: 14px;">💡 Try: "Date night" or "Casual Friday at work"</span>
      </div>

      <div class="step">
        <span class="step-number">3</span>
        <strong>Check out "Complete Your Look"</strong><br>
        <span style="color: #6b7280; font-size: 14px;">🛍️ See what items would complete your wardrobe</span>
      </div>
    </div>

    <center>
      <a href="<%= @app_url %>" class="button">Get Started Now</a>
    </center>

    <p style="margin-top: 30px; color: #6b7280; font-size: 14px;">
      <strong>Questions?</strong> Just reply to this email. I read every message personally.
    </p>

    <p style="margin-top: 20px;">
      Happy styling!<br>
      <strong>[Your Name]</strong><br>
      Founder, OutfitMaker.ai
    </p>

    <p style="margin-top: 20px; padding: 15px; background: #fef3c7; border-left: 4px solid #f59e0b; border-radius: 4px; font-size: 14px;">
      <strong>💡 Pro tip:</strong> OutfitMaker.ai works best on mobile. Install it as an app for quick access!
    </p>
  </div>

  <div class="footer">
    <p>© 2026 OutfitMaker.ai. All rights reserved.</p>
    <p style="font-size: 12px; margin-top: 10px;">
      You're receiving this because you signed up for OutfitMaker.ai.<br>
      <%= link_to "Unsubscribe", unsubscribe_url(@user.id, @user.unsubscribe_token), style: "color: #9ca3af;" %>
    </p>
  </div>
</body>
</html>
```

**File:** `app/views/user_mailer/welcome.text.erb` (plain text version)

```
Welcome to OutfitMaker.ai!

Hi <%= @user.username %>,

Thanks for signing up! You're about to discover how AI can transform your wardrobe.

Here's what to do first:

1. Upload your wardrobe (10-15 items is a great start)
   Tip: Take photos in good lighting. No need for perfection!

2. Request your first outfit
   Try: "Date night" or "Casual Friday at work"

3. Check out "Complete Your Look"
   See what items would complete your wardrobe

Get Started: <%= @app_url %>

Questions? Just reply to this email.

Happy styling!
[Your Name]
Founder, OutfitMaker.ai

---
© 2026 OutfitMaker.ai
Unsubscribe: <%= unsubscribe_url(@user.id, @user.unsubscribe_token) %>
```

### Step 4: Trigger Emails from Controllers

**File:** `app/controllers/users/registrations_controller.rb`

```ruby
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # Send welcome email immediately after signup
        UserMailer.welcome(resource).deliver_later

        # Schedule activation reminder for 24 hours later (if not activated)
        ActivationReminderJob.set(wait: 24.hours).perform_later(resource.id)
      end
    end
  end
end
```

**File:** `app/jobs/activation_reminder_job.rb` (create this file)

```ruby
class ActivationReminderJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)

    # Only send if user hasn't uploaded 5+ items yet
    if user.wardrobe_items.count < 5
      UserMailer.activation_reminder(user).deliver_now
    end
  end
end
```

---

## Part 4: Test Email Delivery (15 minutes)

### Step 1: Test in Development

Add letter_opener_web gem for viewing emails in browser:

**File:** `Gemfile`

```ruby
group :development do
  gem 'letter_opener_web', '~> 2.0'
end
```

Run: `bundle install`

**File:** `config/routes.rb`

```ruby
Rails.application.routes.draw do
  # ... existing routes ...

  # Email preview in development
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
```

**Test it:**
```bash
rails console
> UserMailer.welcome(User.first).deliver_now
```

Then open: http://localhost:3000/letter_opener

You should see the email!

### Step 2: Test in Production

1. Deploy your app with Mailgun configured
2. Sign up with a test email
3. Check your inbox (wait 1-2 minutes)
4. If nothing arrives, check:
   - Mailgun dashboard (logs show if email was sent)
   - Spam folder
   - DNS records verified (green checkmarks in Mailgun)

---

## Part 5: Monitor Email Deliverability (Ongoing)

### Mailgun Dashboard Metrics:

1. Go to Mailgun dashboard → "Analytics"
2. Monitor:
   - **Delivered:** Should be >99%
   - **Opened:** Target 40-60% (depends on subject line)
   - **Clicked:** Target 10-20% (depends on CTA)
   - **Bounced:** Should be <2% (hard bounces = bad emails)
   - **Spam Complaints:** Should be <0.1% (critical!)

### If Deliverability Issues:

**Emails going to spam:**
- Check DNS records verified
- Warm up domain (send slowly at first: 50/day → 200/day → 1000/day)
- Avoid spam trigger words ("free," "act now," "$$$")
- Add unsubscribe link (required by law)

**High bounce rate:**
- Implement email verification on signup
- Use a service like ZeroBounce or NeverBounce
- Remove invalid emails from list

---

## Part 6: Email Best Practices

### Subject Line Tips:

**Good:**
- "Welcome to OutfitMaker.ai! Here's how to get started"
- "You're 3 items away from your first AI outfit"
- "Your trial ends tomorrow - 50% off inside!"

**Bad:**
- "Welcome!!!" (too many exclamation marks)
- "FREE FASHION ADVICE" (all caps = spam)
- "Re: Your account" (looks phishy)

### Content Tips:

✅ **Do:**
- Personalize with user's name
- Keep emails short (under 200 words)
- Single clear CTA button
- Include plain text version
- Add unsubscribe link
- Use real sender name (not "noreply@")

❌ **Don't:**
- Send too frequently (max 1-2 per week)
- Use tiny fonts or hard-to-read colors
- Include large images (slow loading)
- Send from "noreply@" addresses
- Forget mobile optimization

---

## Troubleshooting

**"Mailgun delivery failed":**
- Check API key is correct in `.env`
- Verify domain is verified (green in Mailgun dashboard)
- Check Rails logs: `tail -f log/production.log`

**Emails not sending in production:**
- Check ENV variables set on Railway: `railway variables`
- Verify `perform_deliveries = true` in production.rb
- Check Mailgun logs for error messages

**Devise emails not working:**
- Mailgun is configured but Devise uses different mailer
- Configure Devise mailer separately (see Devise docs)

---

## Next Steps

Once emails are working:
1. ✅ Welcome email sends on signup
2. ✅ Activation reminder sends after 24 hours
3. Create remaining email sequences (engagement, trial ending, re-engagement)
4. Monitor deliverability weekly
5. A/B test subject lines (after 100+ sends)

---

**Questions?** Test each step and let me know if you get stuck!