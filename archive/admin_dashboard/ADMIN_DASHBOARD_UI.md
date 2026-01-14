# Admin Dashboard UI - Implementation Guide

## Overview

This document describes the frontend implementation of the Admin Dashboard for the Outfit Maker app. The UI is built with Tailwind CSS, featuring a glassmorphism design that matches the existing app aesthetic.

## Features Implemented

### 1. Admin Layout (`app/views/layouts/admin.html.erb`)
- Sidebar navigation with sections for Dashboard, Users, Subscriptions, and Usage Analytics
- Glassmorphism design matching app theme
- Responsive layout with fixed sidebar
- Top bar with page title and user info
- Back to app link in sidebar footer

### 2. Dashboard Overview (`app/views/admin/dashboard/index.html.erb`)
- **KPI Cards**:
  - Total Users (with new users this week)
  - Paying Users (with conversion percentage)
  - Monthly Recurring Revenue (with growth percentage)
  - AI Cost This Month (with alert for >$500)
  - Total AI Suggestions (with today's count)
  - Churn Rate (with churned users count)

- **Charts** (using Chartkick):
  - MRR Over Time (line chart, last 90 days)
  - Users by Subscription Tier (pie chart)
  - AI Suggestions Over Time (area chart, last 30 days)

- **Recent Activity Feed**:
  - User signups
  - Subscription upgrades/downgrades
  - Outfit creations
  - Wardrobe item uploads
  - AI suggestion usage

- **Quick Actions**:
  - Links to User Management, Subscription Metrics, and Usage Analytics

### 3. User Management (`app/views/admin/users/index.html.erb`)
- **Search & Filters**:
  - Search by email or user ID
  - Filter by subscription tier (Free, Premium, Pro)
  - Filter by activity status (Active, Inactive)
  - Clear filters button

- **Users Table**:
  - User avatar (first letter of email)
  - Email and ID
  - Subscription tier badge (color-coded)
  - Joined date
  - Last active timestamp
  - Wardrobe items count
  - Outfits count
  - AI suggestions count
  - View details action

- **Stats Summary Cards**:
  - Total users
  - Free tier users
  - Premium users
  - Pro users

- **Pagination**: Using Kaminari with custom styling

### 4. User Details (`app/views/admin/users/show.html.erb`)
- **User Header**:
  - Large avatar with email
  - Current subscription tier badge
  - Last active timestamp
  - **Manual Tier Upgrade Dropdown**:
    - Set to Free
    - Set to Premium
    - Set to Pro
    - Confirmation dialogs for safety

- **Stats Cards**:
  - Wardrobe items (with limit)
  - Outfits created (with last created time)
  - AI suggestions used (with remaining today)
  - Account age (member since)

- **Profile Information**:
  - Gender, Age, Location, Style Preference
  - Only shown if user has completed profile

- **Activity Timeline**:
  - Recent user activities with icons and timestamps

- **Usage Charts**:
  - AI Suggestions Over Time (last 30 days)
  - Wardrobe Growth (last 30 days)

### 5. Subscription Metrics (`app/views/admin/metrics/subscriptions.html.erb`)
- **Revenue KPIs**:
  - Total MRR (with growth vs last month)
  - Premium MRR (with subscriber count)
  - Pro MRR (with subscriber count)
  - ARPU (Average Revenue Per User)

- **Subscription Health**:
  - New subscriptions this month
  - Cancellations this month
  - Churn rate
  - Conversion rate

- **Charts**:
  - MRR Trend (line chart, last 6 months)
  - Subscriber Distribution (column chart)

- **Conversion Funnel**:
  - Visual funnel showing:
    - All users (100%)
    - Users with profile
    - Premium subscribers
    - Pro subscribers

- **Cohort Analysis Table**:
  - Weekly cohorts
  - Retention rates (Week 1, 2, 4)
  - Color-coded retention percentages

- **Recent Subscription Events**:
  - Upgrades, downgrades, cancellations
  - User email and tier change
  - Timestamp

### 6. Usage Analytics (`app/views/admin/metrics/usage.html.erb`)
- **AI Usage KPIs**:
  - Total AI suggestions
  - Suggestions this month
  - AI cost this month (with alert if >$500)
  - Average suggestions per user

- **Feature Usage Stats**:
  - Wardrobe items uploaded (with weekly growth)
  - Outfits created (with weekly growth)
  - Image searches performed (Premium feature)

- **Charts**:
  - AI Suggestions Over Time (area chart, last 30 days)
  - AI Costs Over Time (line chart, last 30 days)
  - Usage by Tier (column chart)

- **Top Contexts Table**:
  - Most common AI suggestion contexts
  - Count and percentage of total

- **Peak Usage Hours**:
  - Heatmap-style visualization (0-23 hours)
  - Color intensity based on usage
  - Shows last 7 days

- **Daily Active Users Chart**:
  - Line chart showing DAU trend (last 30 days)

### 7. Ad Banner Component (`app/views/shared/_ad_banner.html.erb`)
- **Visibility**: Only shown to free tier users
- **Layout**:
  - Advertisement label at top
  - "Remove ads" upgrade link
  - Responsive ad container:
    - Desktop: 728x90 banner
    - Mobile: 320x50 banner
  - Google AdSense integration (configurable via ENV vars)
  - Placeholder shown in development

- **Environment Variables**:
  - `GOOGLE_ADSENSE_CLIENT_ID`: Your AdSense publisher ID
  - `GOOGLE_ADSENSE_SLOT_ID`: Desktop ad slot ID
  - `GOOGLE_ADSENSE_MOBILE_SLOT_ID`: Mobile ad slot ID

- **Integration Example**:
  - Added to home dashboard (`app/views/pages/home.html.erb`)
  - Can be added to any view

## Helper Methods

Created in `app/helpers/admin_helper.rb`:

### Tier Badge Colors
```ruby
tier_badge_color(tier)
# Returns Tailwind classes for tier badges
# - Free: gray
# - Premium: purple
# - Pro: pink
```

### Retention Colors
```ruby
retention_color(rate)
# Color-codes retention percentages:
# - >= 70%: green
# - >= 50%: yellow
# - >= 30%: orange
# - < 30%: red
```

### Usage Intensity Colors
```ruby
usage_intensity_color(intensity)
# Returns background color for heatmap cells
# Based on intensity percentage (0-100)
```

### Format Numbers
```ruby
format_number(number)
# Formats large numbers with K/M suffix
# 1,000 -> 1K
# 1,000,000 -> 1M
```

### Activity Icons & Colors
```ruby
activity_icon(type, size: 'w-4 h-4')
# Returns SVG icon for activity type

activity_color(type)
# Returns gradient background color for activity
```

### Event Badge Colors
```ruby
event_badge_color(event_type)
# Returns Tailwind classes for subscription events
```

## Stimulus Controllers

### Dropdown Controller (`app/javascript/controllers/dropdown_controller.js`)
- Toggles dropdown menus (e.g., tier upgrade dropdown)
- Closes on outside click
- Auto-cleanup on disconnect

## Design System

### Color Palette
- **Primary**: Purple (`rgb(168, 85, 247)`)
- **Secondary**: Pink/Cyan (`rgb(236, 72, 153)`)
- **Background**: Dark slate (`hsl(222 47% 11%)`)
- **Cards**: Glassmorphism effect with backdrop blur

### Typography
- Font: Inter
- Headings: Bold, white
- Body text: Gray-400
- Links: Primary color with hover effect

### Components
- **Glass Cards**: Backdrop blur, border, shadow
- **KPI Cards**: Icon, metric, label, trend
- **Tables**: Hover effects, bordered rows
- **Charts**: Dark theme with consistent colors
- **Badges**: Color-coded by tier/status

## Dependencies

### Gems Added
```ruby
gem "chartkick"   # Charts
gem "groupdate"   # Date grouping for charts
gem "kaminari"    # Pagination
```

### NPM Packages Added
```bash
npm install chartkick chart.js
```

### JavaScript Import
```javascript
// app/javascript/application.js
import "chartkick/chart.js"
```

## Routing

Routes need to be added to `config/routes.rb`:

```ruby
namespace :admin do
  root to: 'dashboard#index'

  resources :users, only: [:index, :show] do
    member do
      patch :update_tier
    end
  end

  namespace :metrics do
    get 'subscriptions', to: 'metrics#subscriptions'
    get 'usage', to: 'metrics#usage'
  end
end
```

## Backend Requirements

The views expect the following instance variables to be provided by controllers:

### DashboardController#index
- `@total_users`, `@new_users_this_week`
- `@paying_users`, `@paying_percentage`
- `@mrr`, `@arpu`, `@mrr_growth_percentage`
- `@ai_cost_this_month`, `@ai_suggestions_this_month`
- `@total_suggestions`, `@suggestions_today`
- `@churn_rate`, `@churned_users_this_month`
- `@mrr_over_time` (hash: date => value)
- `@users_by_tier` (hash: tier => count)
- `@suggestions_over_time` (hash: date => count)
- `@recent_activities` (array of hashes with :icon, :text, :time, :color)

### UsersController#index
- `@users` (paginated collection)
- `@free_count`, `@premium_count`, `@pro_count`

### UsersController#show
- `@user` (User model)
- `@recent_activities` (array of activity hashes)
- `@user_suggestions_over_time` (hash: date => count)
- `@user_wardrobe_growth` (hash: date => count)

### MetricsController#subscriptions
- Revenue metrics: `@total_mrr`, `@premium_mrr`, `@pro_mrr`, `@arpu`
- Health: `@new_subscriptions_this_month`, `@cancellations_this_month`, `@churn_rate`, `@conversion_rate`
- Charts: `@mrr_trend`, `@subscriber_distribution`
- Funnel: `@total_users`, `@users_with_profile`, `@premium_count`, `@pro_count`
- Percentages: `@profile_completion_rate`, `@premium_conversion_rate`, `@pro_conversion_rate`
- `@cohort_data` (array of hashes with retention data)
- `@recent_subscription_events` (array of event hashes)

### MetricsController#usage
- `@total_suggestions`, `@suggestions_today`, `@suggestions_this_month`
- `@ai_cost_this_month`, `@avg_suggestions_per_user`
- `@total_wardrobe_items`, `@wardrobe_items_this_week`
- `@total_outfits`, `@outfits_this_week`
- `@total_image_searches`
- Charts: `@suggestions_over_time`, `@ai_costs_over_time`, `@usage_by_tier`
- `@top_contexts` (hash: context => count)
- `@hourly_usage` (hash: hour => count)
- `@daily_active_users` (hash: date => count)

## Usage Example

### Setting Up AdSense

1. Sign up for Google AdSense at https://www.google.com/adsense/
2. Add your site and verify ownership
3. Create ad units (responsive banner)
4. Add to `.env`:
```bash
GOOGLE_ADSENSE_CLIENT_ID=ca-pub-XXXXXXXXXXXXXX
GOOGLE_ADSENSE_SLOT_ID=XXXXXXXXXX
GOOGLE_ADSENSE_MOBILE_SLOT_ID=XXXXXXXXXX
```

### Adding Ad Banner to Views

Simply include the partial:
```erb
<%= render "shared/ad_banner" %>
```

The component automatically:
- Shows only to free tier users
- Hides for Premium/Pro users
- Displays responsive ads (desktop/mobile)
- Includes upgrade CTA

## Responsive Design

All views are fully responsive:
- **Mobile**: Single column layout, stacked cards
- **Tablet**: 2-column grids where appropriate
- **Desktop**: 3-4 column grids, sidebar navigation

## Accessibility

- Semantic HTML5 elements
- ARIA labels for screen readers
- Keyboard navigation support
- Color contrast meets WCAG standards
- Focus states on interactive elements

## Browser Support

- Chrome/Edge (last 2 versions)
- Firefox (last 2 versions)
- Safari (last 2 versions)
- Modern mobile browsers

## Next Steps

To complete the admin dashboard:

1. **Backend Implementation**:
   - Create admin controllers
   - Implement analytics service classes
   - Add admin authentication
   - Set up routes

2. **Database**:
   - Add admin flag to users table
   - Add indexes for admin queries
   - Create ad_impressions table (optional)

3. **Testing**:
   - System tests for admin flows
   - Authorization tests
   - Chart rendering tests

4. **Deployment**:
   - Configure AdSense in production
   - Set environment variables
   - Monitor performance

## File Structure

```
app/
├── views/
│   ├── layouts/
│   │   └── admin.html.erb
│   ├── admin/
│   │   ├── dashboard/
│   │   │   └── index.html.erb
│   │   ├── users/
│   │   │   ├── index.html.erb
│   │   │   └── show.html.erb
│   │   └── metrics/
│   │       ├── subscriptions.html.erb
│   │       └── usage.html.erb
│   └── shared/
│       └── _ad_banner.html.erb
├── helpers/
│   └── admin_helper.rb
└── javascript/
    └── controllers/
        └── dropdown_controller.js
```

## Screenshots & Demo

Visit `/admin` (with admin privileges) to see:
- Dashboard overview with live metrics
- User management with search/filter
- Detailed user profiles with tier upgrade
- Subscription metrics with cohort analysis
- Usage analytics with AI cost tracking

## Support

For questions or issues, contact the development team or refer to:
- Tailwind CSS: https://tailwindcss.com/docs
- Chartkick: https://chartkick.com/
- Stimulus: https://stimulus.hotwired.dev/

---

**Status**: Ready for backend integration
**Last Updated**: 2025-12-11
**Branch**: `feature/admin-dashboard-ui`
