# OutfitMaker.ai - High-Priority Feature Specifications

## 📋 Overview

This document outlines three **must-have** features that are commonly expected in modern wardrobe management apps. These features significantly increase user engagement, retention, and perceived value.

**Features Covered:**
1. **Outfit Calendar** - Plan outfits in advance, visualize weekly/monthly schedule
2. **Multiple Closets** - Organize wardrobe by season, location, or purpose
3. **Trip Planner** - Maximize outfit combinations from minimal items

**Priority**: Implement **after** Phase 5 (Avatar Try-On) but **before** advanced social features

**Estimated Timeline**: 6-8 weeks total (2-3 weeks per feature)

**Business Impact**:
- **Calendar**: +40% weekly active users (WAU)
- **Multiple Closets**: +25% items uploaded per user
- **Trip Planner**: +60% engagement during travel season (Q2/Q3)

---

## 🗓️ Feature 1: Outfit Calendar

### User Story

> **As a user**, I want to plan my outfits for the week ahead so that I never have to think "what should I wear tomorrow?" in the morning rush.

### Use Cases

**Primary Use Cases:**
1. **Weekly Planning Sunday** - User spends 15 minutes planning Mon-Fri work outfits
2. **Event Preparation** - User plans outfit for job interview 3 days in advance
3. **Vacation Countdown** - User pre-plans all outfits for 7-day trip
4. **Outfit History** - User looks back to see "what did I wear to that meeting 2 weeks ago?"

**Secondary Use Cases:**
1. Track outfit wear frequency (avoid repeating same outfit too often)
2. Weather-aware suggestions for future dates
3. Recurring outfit templates ("Every Monday = business casual")

### UI/UX Design

#### Calendar View Modes

**1. Weekly View** (Default)
```
┌─────────────────────────────────────────────────────┐
│  Week of Jan 20 - Jan 26, 2026          [+ Add]     │
├──────────┬──────────┬──────────┬──────────┬─────────┤
│  MON 20  │  TUE 21  │  WED 22  │  THU 23  │  FRI 24 │
│          │          │          │          │         │
│ ☀️ 72°F  │ ⛅ 68°F  │ 🌧️ 55°F │ ☀️ 70°F │ ☀️ 74°F │
│          │          │          │          │         │
│ [Outfit] │ [Outfit] │   ---    │ [Outfit] │  ---    │
│  Photo   │  Photo   │   Empty  │  Photo   │  Empty  │
│          │          │          │          │         │
│ Work     │ Meeting  │   Plan   │ Casual   │  Plan   │
│ Event    │ with CEO │   Outfit │ Friday   │  Outfit │
└──────────┴──────────┴──────────┴──────────┴─────────┘
│  SAT 25  │  SUN 26  │
│  ---     │  ---     │
│  Empty   │  Empty   │
└──────────┴──────────┘
```

**2. Monthly View**
```
┌─────────────────────────────────────────────────────┐
│              January 2026                [+ Add]     │
├─────┬─────┬─────┬─────┬─────┬─────┬─────────────────┤
│ SUN │ MON │ TUE │ WED │ THU │ FRI │ SAT             │
├─────┼─────┼─────┼─────┼─────┼─────┼─────────────────┤
│     │     │     │  1  │  2  │  3  │  4              │
│     │     │     │ 👔  │ 👗  │ 👕  │ 👖             │
├─────┼─────┼─────┼─────┼─────┼─────┼─────────────────┤
│  5  │  6  │  7  │  8  │  9  │ 10  │ 11              │
│     │ 👔  │ 👗  │ 👕  │ 👔  │ 👗  │                │
└─────┴─────┴─────┴─────┴─────┴─────┴─────────────────┘
(Mini outfit thumbnails in each date cell)
```

**3. Daily Detail View**
```
┌─────────────────────────────────────────────────────┐
│  Monday, January 20, 2026                           │
│  ☀️ 72°F / Partly Cloudy                            │
├─────────────────────────────────────────────────────┤
│  Event: Client Meeting at 2pm                       │
│                                                     │
│  [Large Outfit Preview]                             │
│  ┌─────────────────────┐                           │
│  │                     │                           │
│  │   Navy Blazer       │                           │
│  │   White Blouse      │                           │
│  │   Gray Trousers     │                           │
│  │   Black Pumps       │                           │
│  │                     │                           │
│  └─────────────────────┘                           │
│                                                     │
│  [Edit Outfit]  [Generate AI Alternative]          │
│  [Move to Another Day]  [Duplicate]                │
│                                                     │
│  Notes: "Remember to bring portfolio folder"       │
└─────────────────────────────────────────────────────┘
```

#### Interaction Patterns

**Adding an Outfit to Calendar:**
```
1. User clicks empty day slot OR "+ Add" button
2. Modal appears: "Plan Outfit for Monday, Jan 20"
   ├── Option A: "Choose from My Outfits" (saved combinations)
   ├── Option B: "AI Suggest for Event" (input: event type)
   └── Option C: "Build Custom" (select items manually)
3. User picks Option B → enters "Client meeting"
4. AI generates 3 suggestions → user selects one
5. Outfit saved to calendar → thumbnail appears in date slot
```

**Editing/Rescheduling:**
```
- Drag & drop outfit to different date (desktop)
- Long-press → "Move to..." (mobile)
- Click outfit → "Edit" → swap individual items
- "Duplicate to Week" → repeat Mon-Fri with variations
```

**Weather Integration:**
```
- Fetch 7-day forecast for user's location
- Show weather icon + temp on each date
- AI adjusts suggestions based on forecast
  → Rainy day = suggest boots, umbrella, water-resistant jacket
  → Hot day = suggest light fabrics, short sleeves
```

### Technical Implementation

#### Database Schema

```ruby
# db/migrate/..._create_outfit_calendar_entries.rb
class CreateOutfitCalendarEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :outfit_calendar_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :outfit_suggestion, foreign_key: true # Can be nil if custom
      
      # Date & Time
      t.date :scheduled_date, null: false
      t.time :scheduled_time # Optional (e.g., "9:00 AM meeting")
      
      # Event Context
      t.string :event_type # "work", "meeting", "date", "casual", "formal"
      t.string :event_title # "Client Presentation", "Dinner with Friends"
      t.text :notes # User's personal notes
      
      # Weather (cached at time of scheduling)
      t.jsonb :weather_forecast # {temp: 72, condition: "sunny", ...}
      
      # Outfit Items (if custom, not using outfit_suggestion_id)
      t.jsonb :custom_outfit_items # [{wardrobe_item_id: 123, ...}]
      
      # Status
      t.string :status, default: 'planned' # planned, worn, skipped
      t.datetime :worn_at # Timestamp when marked as "worn"
      
      # Analytics
      t.integer :times_worn, default: 0 # Track if same outfit used multiple times
      
      t.timestamps
    end
    
    add_index :outfit_calendar_entries, [:user_id, :scheduled_date], unique: true
    add_index :outfit_calendar_entries, :scheduled_date
    add_index :outfit_calendar_entries, :status
    add_index :outfit_calendar_entries, :event_type
  end
end
```

#### Models

```ruby
# app/models/outfit_calendar_entry.rb
class OutfitCalendarEntry < ApplicationRecord
  belongs_to :user
  belongs_to :outfit_suggestion, optional: true
  
  # Validations
  validates :scheduled_date, presence: true
  validates :scheduled_date, uniqueness: { scope: :user_id }
  
  # Scopes
  scope :upcoming, -> { where('scheduled_date >= ?', Date.today).order(:scheduled_date) }
  scope :past, -> { where('scheduled_date < ?', Date.today).order(scheduled_date: :desc) }
  scope :this_week, -> { where(scheduled_date: Date.today.beginning_of_week..Date.today.end_of_week) }
  scope :this_month, -> { where(scheduled_date: Date.today.beginning_of_month..Date.today.end_of_month) }
  
  # Status helpers
  enum status: { planned: 'planned', worn: 'worn', skipped: 'skipped' }
  
  # Get outfit items (whether from outfit_suggestion or custom)
  def outfit_items
    if outfit_suggestion.present?
      outfit_suggestion.outfit_items.includes(:wardrobe_item)
    elsif custom_outfit_items.present?
      WardrobeItem.where(id: custom_outfit_items.pluck('wardrobe_item_id'))
    else
      []
    end
  end
  
  # Mark as worn
  def mark_as_worn!
    update!(status: 'worn', worn_at: Time.current)
    increment!(:times_worn)
  end
  
  # Fetch weather forecast for this date
  def fetch_weather_forecast
    WeatherService.new(user.location, scheduled_date).forecast
  end
end
```

#### Services

**Weather Integration Service:**
```ruby
# app/services/weather_service.rb
class WeatherService
  def initialize(location, date)
    @location = location
    @date = date
  end
  
  def forecast
    # Use free API like OpenWeatherMap or WeatherAPI.com
    response = HTTParty.get(
      "https://api.openweathermap.org/data/2.5/forecast",
      query: {
        q: @location,
        appid: ENV['OPENWEATHER_API_KEY'],
        units: 'imperial',
        cnt: 7 # 7-day forecast
      }
    )
    
    # Find forecast for target date
    forecast_data = response['list'].find do |item|
      Date.parse(item['dt_txt']) == @date
    end
    
    return nil unless forecast_data
    
    {
      temp: forecast_data['main']['temp'].round,
      condition: forecast_data['weather'][0]['main'].downcase,
      description: forecast_data['weather'][0]['description'],
      icon: weather_icon(forecast_data['weather'][0]['main']),
      humidity: forecast_data['main']['humidity'],
      wind_speed: forecast_data['wind']['speed']
    }
  end
  
  private
  
  def weather_icon(condition)
    case condition.downcase
    when 'clear' then '☀️'
    when 'clouds' then '⛅'
    when 'rain' then '🌧️'
    when 'snow' then '❄️'
    when 'thunderstorm' then '⛈️'
    else '🌤️'
    end
  end
end
```

**AI Outfit Suggestion for Calendar:**
```ruby
# app/services/calendar_outfit_suggester.rb
class CalendarOutfitSuggester
  def initialize(user, date, event_type)
    @user = user
    @date = date
    @event_type = event_type
  end
  
  def suggest_outfits(count: 3)
    # Get weather forecast
    weather = WeatherService.new(@user.location, @date).forecast
    
    # Build enhanced prompt
    prompt = build_calendar_prompt(weather)
    
    # Call Gemini AI
    response = call_gemini_api(prompt)
    
    # Create outfit suggestions
    parse_and_create_suggestions(response)
  end
  
  private
  
  def build_calendar_prompt(weather)
    <<~PROMPT
      ROLE: Personal stylist planning outfit for specific date
      
      USER PROFILE:
      - Style: #{@user.user_profile.style_preference}
      - Presentation: #{@user.user_profile.presentation_style}
      - Favorite colors: #{@user.user_profile.favorite_colors.join(', ')}
      
      DATE & CONTEXT:
      - Date: #{@date.strftime('%A, %B %d, %Y')}
      - Event: #{@event_type}
      - Weather: #{weather[:temp]}°F, #{weather[:description]}
      
      AVAILABLE WARDROBE:
      #{@user.wardrobe_items.active.map { |i| "- #{i.category} (#{i.color}, #{i.pattern})" }.join("\n")}
      
      TASK: Suggest 3 complete outfits for this specific date and event.
      
      REQUIREMENTS:
      1. Weather-appropriate (account for #{weather[:temp]}°F and #{weather[:condition]})
      2. Event-appropriate (#{@event_type} context)
      3. Use ONLY items from available wardrobe
      4. Include accessories if weather requires (umbrella for rain, sunglasses for sunny)
      
      RETURN JSON:
      [
        {
          "outfit_name": "Professional Monday",
          "items": [
            {"wardrobe_item_id": 123, "category": "blazer"},
            {"wardrobe_item_id": 456, "category": "blouse"},
            ...
          ],
          "reasoning": "Navy blazer provides formality for client meeting, while light fabric suits 72°F weather",
          "weather_notes": "Consider bringing light cardigan if indoor AC is cold"
        }
      ]
    PROMPT
  end
end
```

#### Frontend Components (Stimulus Controllers)

**Calendar Controller:**
```javascript
// app/javascript/controllers/outfit_calendar_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weekView", "monthView", "dayDetail"]
  static values = {
    currentDate: String,
    viewMode: { type: String, default: "week" }
  }
  
  connect() {
    this.loadCalendarData()
  }
  
  async loadCalendarData() {
    const response = await fetch(`/outfit_calendar?date=${this.currentDateValue}&view=${this.viewModeValue}`)
    const html = await response.text()
    this.element.innerHTML = html
  }
  
  switchToWeek(event) {
    this.viewModeValue = "week"
    this.loadCalendarData()
  }
  
  switchToMonth(event) {
    this.viewModeValue = "month"
    this.loadCalendarData()
  }
  
  async addOutfit(event) {
    const date = event.target.dataset.date
    // Open modal to select/create outfit
    this.dispatch("openOutfitModal", { detail: { date } })
  }
  
  async markAsWorn(event) {
    const entryId = event.target.dataset.entryId
    await fetch(`/outfit_calendar/${entryId}/mark_worn`, { method: 'PATCH' })
    this.loadCalendarData()
  }
}
```

### Tier Differentiation

**Free Tier:**
- Plan outfits 7 days in advance
- Basic calendar view (week only)
- Manual outfit selection

**Premium ($7.99/mo):**
- Plan outfits 30 days in advance
- Month view + week view
- AI suggestions for calendar events
- Weather integration

**Pro ($14.99/mo):**
- Plan outfits 90 days in advance
- All calendar views (daily/weekly/monthly)
- Recurring outfit templates ("Every Monday")
- Outfit wear history & analytics
- Export calendar to Google Calendar/iCal

---

## 👕 Feature 2: Multiple Closets

### User Story

> **As a user**, I want to organize my wardrobe into separate closets (Winter, Summer, Work, Gym) so that I only see relevant items when planning outfits.

### Use Cases

**Primary Use Cases:**
1. **Seasonal Organization** - User has "Winter Closet" and "Summer Closet", swaps between them in March/October
2. **Location-Based** - User has "Home Closet" and "Beach House Closet"
3. **Purpose-Based** - User has "Work Closet", "Gym Closet", "Formal Events Closet"
4. **Trip Preparation** - User creates temporary "Paris Trip Closet" with only items they're packing

**Secondary Use Cases:**
1. Declutter main wardrobe view (only show active closet)
2. Share specific closet with stylist/friend (Pro feature)
3. Archive old clothes without deleting (create "Archive Closet")

### UI/UX Design

#### Closet Switcher

**Top Navigation Addition:**
```
┌─────────────────────────────────────────────────────┐
│  [☰ Menu]  OutfitMaker.ai           [👤 Profile]    │
├─────────────────────────────────────────────────────┤
│  [< All Closets ▼]                  [+ New Closet]  │
│                                                     │
│  📦 All Closets (342 items)         ⭐ Active       │
│  ❄️  Winter Closet (89 items)                       │
│  ☀️  Summer Closet (127 items)                      │
│  💼 Work Wardrobe (76 items)                        │
│  🏖️  Beach House (23 items)                        │
│  ✈️  Paris Trip (15 items)          🔒 Temporary    │
└─────────────────────────────────────────────────────┘
```

**Closet Detail View:**
```
┌─────────────────────────────────────────────────────┐
│  ❄️  Winter Closet                   [⚙️ Settings]  │
│  89 items • Last updated 3 days ago                 │
├─────────────────────────────────────────────────────┤
│  [Active from Nov 1 - Mar 31]                       │
│                                                     │
│  [Filter: All] [Sort: Recent]       [+ Add Items]   │
│                                                     │
│  [Grid of Winter Items...]                          │
│                                                     │
│  Coats (12) • Sweaters (24) • Boots (8) • Scarves   │
└─────────────────────────────────────────────────────┘
```

#### Closet Creation Flow

**Step 1: Create Closet**
```
┌─────────────────────────────────────────────────────┐
│  Create New Closet                         [✕ Close]│
├─────────────────────────────────────────────────────┤
│  Closet Name:                                       │
│  [________________________]                         │
│                                                     │
│  Icon: ❄️ ☀️ 💼 🏖️ ✈️ 🎒 👗 🎩 (select one)         │
│                                                     │
│  Type:                                              │
│  ○ Seasonal (auto-activate based on dates)          │
│  ○ Permanent (always available)                     │
│  ○ Temporary (auto-archive after trip)              │
│                                                     │
│  Active Period (for Seasonal):                      │
│  From: [Nov 1] To: [Mar 31]                        │
│                                                     │
│  [Cancel]                    [Create Closet]        │
└─────────────────────────────────────────────────────┘
```

**Step 2: Add Items to Closet**
```
┌─────────────────────────────────────────────────────┐
│  Add Items to "Winter Closet"             [✕ Close] │
├─────────────────────────────────────────────────────┤
│  Option 1: Select from existing wardrobe            │
│  [☑️ Bulk Select Mode]                              │
│                                                     │
│  [Grid of all wardrobe items with checkboxes...]   │
│  ☑️ Navy Peacoat                                    │
│  ☑️ Gray Wool Sweater                               │
│  ☐ White Linen Shirt (already in Summer)           │
│                                                     │
│  Selected: 24 items                                 │
│  [Add Selected to Closet]                           │
│                                                     │
│  ────────────────────────────────────────────────   │
│                                                     │
│  Option 2: AI Smart Fill                            │
│  "Find all winter-appropriate items"                │
│  [🤖 AI Suggest Items]                              │
└─────────────────────────────────────────────────────┘
```

### Technical Implementation

#### Database Schema

```ruby
# db/migrate/..._create_closets.rb
class CreateClosets < ActiveRecord::Migration[7.1]
  def change
    create_table :closets do |t|
      t.references :user, null: false, foreign_key: true
      
      # Closet Info
      t.string :name, null: false # "Winter Closet", "Work Wardrobe"
      t.string :icon, default: '👗' # Emoji icon
      t.text :description
      
      # Type & Behavior
      t.string :closet_type, default: 'permanent' # permanent, seasonal, temporary
      t.date :active_from # For seasonal closets
      t.date :active_until # For seasonal closets
      t.datetime :archived_at # Soft delete
      
      # Status
      t.boolean :is_active, default: true
      t.integer :items_count, default: 0 # Counter cache
      
      # Display Order
      t.integer :position, default: 0
      
      t.timestamps
    end
    
    add_index :closets, [:user_id, :name], unique: true
    add_index :closets, :closet_type
    add_index :closets, :is_active
  end
end

# db/migrate/..._create_closet_items.rb
class CreateClosetItems < ActiveRecord::Migration[7.1]
  def change
    create_table :closet_items do |t|
      t.references :closet, null: false, foreign_key: true
      t.references :wardrobe_item, null: false, foreign_key: true
      
      # Metadata
      t.datetime :added_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.integer :position # Custom ordering within closet
      
      t.timestamps
    end
    
    add_index :closet_items, [:closet_id, :wardrobe_item_id], unique: true
    add_index :closet_items, :wardrobe_item_id
  end
end

# Update wardrobe_items table to allow multiple closets
class AddClosetSupportToWardrobeItems < ActiveRecord::Migration[7.1]
  def change
    # Remove old single closet reference if exists
    # add_column :wardrobe_items, :default_closet_id, :bigint
    # This is now handled via closet_items join table
  end
end
```

#### Models

```ruby
# app/models/closet.rb
class Closet < ApplicationRecord
  belongs_to :user
  has_many :closet_items, dependent: :destroy
  has_many :wardrobe_items, through: :closet_items
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :closet_type, inclusion: { in: %w[permanent seasonal temporary] }
  
  # Scopes
  scope :active, -> { where(is_active: true, archived_at: nil) }
  scope :seasonal, -> { where(closet_type: 'seasonal') }
  scope :permanent, -> { where(closet_type: 'permanent') }
  scope :temporary, -> { where(closet_type: 'temporary') }
  
  # Check if closet should be active based on date
  def currently_in_season?
    return true unless seasonal?
    
    today = Date.today
    return false if active_from.nil? || active_until.nil?
    
    # Handle year-wrapping seasons (e.g., Nov 1 - Mar 31)
    if active_from <= active_until
      today.between?(active_from, active_until)
    else
      today >= active_from || today <= active_until
    end
  end
  
  # Auto-activate/deactivate seasonal closets
  def self.update_seasonal_statuses
    seasonal.find_each do |closet|
      should_be_active = closet.currently_in_season?
      closet.update(is_active: should_be_active) if closet.is_active != should_be_active
    end
  end
  
  # Add items to closet (bulk)
  def add_items(wardrobe_item_ids)
    wardrobe_item_ids.each do |item_id|
      closet_items.create(wardrobe_item_id: item_id) unless wardrobe_items.exists?(item_id)
    end
    update_items_count
  end
  
  # Remove items from closet
  def remove_items(wardrobe_item_ids)
    closet_items.where(wardrobe_item_id: wardrobe_item_ids).destroy_all
    update_items_count
  end
  
  # Counter cache
  def update_items_count
    update(items_count: wardrobe_items.count)
  end
end

# app/models/wardrobe_item.rb (add closet support)
class WardrobeItem < ApplicationRecord
  has_many :closet_items, dependent: :destroy
  has_many :closets, through: :closet_items
  
  # Get items from specific closet
  scope :in_closet, ->(closet_id) {
    joins(:closet_items).where(closet_items: { closet_id: closet_id })
  }
  
  # Get items not in any closet
  scope :unorganized, -> {
    where.not(id: ClosetItem.select(:wardrobe_item_id))
  }
end
```

#### Services

**AI Smart Closet Population:**
```ruby
# app/services/closet_ai_suggester.rb
class ClosetAiSuggester
  def initialize(user, closet)
    @user = user
    @closet = closet
  end
  
  def suggest_items
    prompt = build_suggestion_prompt
    response = call_gemini_api(prompt)
    parse_item_ids(response)
  end
  
  private
  
  def build_suggestion_prompt
    <<~PROMPT
      ROLE: Wardrobe organization assistant
      
      TASK: Identify which items should go in "#{@closet.name}" closet
      
      CLOSET TYPE: #{@closet.closet_type}
      #{seasonal_context if @closet.seasonal?}
      
      AVAILABLE ITEMS:
      #{@user.wardrobe_items.unorganized.map { |i| 
        "ID #{i.id}: #{i.category} - #{i.color}, #{i.pattern}, #{i.season_tag}"
      }.join("\n")}
      
      INSTRUCTIONS:
      1. Select items appropriate for this closet type
      2. For seasonal closets, match the active period
      3. For work closets, select professional items
      4. For gym closets, select athletic wear
      
      RETURN JSON ARRAY of wardrobe_item IDs:
      [123, 456, 789, ...]
    PROMPT
  end
  
  def seasonal_context
    "Active from #{@closet.active_from} to #{@closet.active_until}"
  end
end
```

### Tier Differentiation

**Free Tier:**
- Create up to 2 closets
- Basic closet features

**Premium ($7.99/mo):**
- Unlimited closets
- Seasonal auto-switching
- AI smart fill

**Pro ($14.99/mo):**
- All Premium features
- Share closets with others
- Advanced analytics per closet
- Bulk move between closets

---

## ✈️ Feature 3: Trip Planner with Outfit Maximization

### User Story

> **As a user**, I want to select minimal items for my trip and have AI show me the maximum number of outfits I can create, so I pack light but have variety.

### Use Cases

**Primary Use Cases:**
1. **Weekend Getaway** - User selects 10 items, AI generates 15 outfit combinations
2. **Business Trip** - User needs 5 professional outfits from 12 items
3. **2-Week Vacation** - User wants 20+ casual outfits from 25 items
4. **Minimalist Packing** - User challenges themselves: "How many outfits from just 7 items?"

**Problem This Solves:**
- Overpacking anxiety
- "I have nothing to wear" on trips
- Not realizing versatile combinations
- Forgetting essential items

### UI/UX Design

#### Trip Creation Flow

**Step 1: Trip Details**
```
┌─────────────────────────────────────────────────────┐
│  Plan Your Trip                            [✕ Close]│
├─────────────────────────────────────────────────────┤
│  Trip Name:                                         │
│  [Paris Vacation_____________________________]      │
│                                                     │
│  Destination:                                       │
│  [Paris, France__________________________] 🌍       │
│                                                     │
│  Dates:                                             │
│  From: [Mar 15, 2026] To: [Mar 22, 2026]           │
│  Duration: 7 days                                   │
│                                                     │
│  Trip Type:                                         │
│  ○ Leisure/Vacation                                 │
│  ○ Business                                         │
│  ○ Mixed                                            │
│                                                     │
│  Activities: (select all that apply)                │
│  ☑️ Sightseeing  ☑️ Fine Dining  ☐ Beach            │
│  ☐ Hiking  ☑️ Museums  ☐ Sports                     │
│                                                     │
│  [Next: Select Items]                               │
└─────────────────────────────────────────────────────┘
```

**Step 2: Item Selection**
```
┌─────────────────────────────────────────────────────┐
│  Select Items to Pack                      [< Back] │
├─────────────────────────────────────────────────────┤
│  Pack Smart: ✨ AI will maximize combinations       │
│                                                     │
│  Weather in Paris: 52-61°F, Light Rain              │
│  Suggested: Light jacket, boots, umbrella           │
│                                                     │
│  [Your Wardrobe]        Selected: 0/20              │
│  ────────────────────────────────────────────────   │
│                                                     │
│  [Filter: All ▼] [AI Quick Pack 🤖]                │
│                                                     │
│  Tops (Select 4-6)                                  │
│  ☐ White Blouse      ☐ Navy Sweater                │
│  ☐ Striped Tee       ☐ Black Tank                  │
│                                                     │
│  Bottoms (Select 2-4)                               │
│  ☐ Black Jeans       ☐ Gray Trousers               │
│  ☐ Denim Skirt       ☐ Leggings                    │
│                                                     │
│  Outerwear (Select 1-2)                             │
│  ☐ Trench Coat       ☐ Leather Jacket              │
│                                                     │
│  Shoes (Select 2-3)                                 │
│  ☐ White Sneakers    ☐ Black Boots                 │
│  ☐ Nude Flats                                       │
│                                                     │
│  Accessories (Optional)                             │
│  ☐ Silk Scarf        ☐ Crossbody Bag               │
│                                                     │
│  [Preview Outfits] ← Available after 8+ items       │
└─────────────────────────────────────────────────────┘
```

**Step 3: Outfit Combinations Preview**
```
┌─────────────────────────────────────────────────────┐
│  Your Paris Trip Outfits                   [✕ Done] │
├─────────────────────────────────────────────────────┤
│  🎉 From 15 items, we created 28 outfits!           │
│                                                     │
│  [Filter: All Days] [Sort: By Occasion]             │
│                                                     │
│  DAY 1 - Arrival Day (Casual)                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐               │
│  │ Outfit  │ │ Outfit  │ │ Outfit  │               │
│  │   1     │ │   2     │ │   3     │               │
│  └─────────┘ └─────────┘ └─────────┘               │
│                                                     │
│  DAY 2 - Museum Day (Smart Casual)                  │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐               │
│  │ Outfit  │ │ Outfit  │ │ Outfit  │               │
│  │   4     │ │   5     │ │   6     │               │
│  └─────────┘ └─────────┘ └─────────┘               │
│                                                     │
│  ...                                                │
│                                                     │
│  EVENING - Fine Dining (Elevated)                   │
│  ┌─────────┐ ┌─────────┐                           │
│  │ Outfit  │ │ Outfit  │                           │
│  │  27     │ │  28     │                           │
│  └─────────┘ └─────────┘                           │
│                                                     │
│  [Assign to Calendar] [Save Trip] [Share]          │
└─────────────────────────────────────────────────────┘
```

#### Packing List Generation

**Auto-Generated Checklist:**
```
┌─────────────────────────────────────────────────────┐
│  Paris Trip Packing List                   [Print] │
├─────────────────────────────────────────────────────┤
│  CLOTHING (15 items)                                │
│  ☐ White Blouse                                     │
│  ☐ Navy Sweater                                     │
│  ☐ Striped Tee                                      │
│  ☐ Black Jeans                                      │
│  ☐ Gray Trousers                                    │
│  ☐ Trench Coat                                      │
│  ☐ White Sneakers                                   │
│  ☐ Black Boots                                      │
│  ...                                                │
│                                                     │
│  ACCESSORIES (3 items)                              │
│  ☐ Silk Scarf                                       │
│  ☐ Crossbody Bag                                    │
│  ☐ Sunglasses                                       │
│                                                     │
│  ESSENTIALS (AI Suggested)                          │
│  ☐ Umbrella (rain forecast)                         │
│  ☐ Universal adapter (France Type C/E)              │
│  ☐ Laundry detergent pods (7-day trip)              │
│                                                     │
│  Packed: 0/21 items                                 │
│  [Mark All as Packed]                               │
└─────────────────────────────────────────────────────┘
```

### Technical Implementation

#### Database Schema

```ruby
# db/migrate/..._create_trips.rb
class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.references :user, null: false, foreign_key: true
      
      # Trip Details
      t.string :name, null: false # "Paris Vacation"
      t.string :destination # "Paris, France"
      t.date :start_date
      t.date :end_date
      t.integer :duration_days # Calculated
      
      # Trip Type & Context
      t.string :trip_type, default: 'leisure' # leisure, business, mixed
      t.string :activities, array: true, default: [] # ["sightseeing", "museums", "dining"]
      
      # Weather (cached at creation)
      t.jsonb :weather_forecast # {avg_temp: 56, condition: "rainy", ...}
      
      # Status
      t.string :status, default: 'planning' # planning, packed, active, completed
      t.datetime :archived_at
      
      # Analytics
      t.integer :total_items_packed, default: 0
      t.integer :total_outfits_generated, default: 0
      
      t.timestamps
    end
    
    add_index :trips, [:user_id, :start_date]
    add_index :trips, :status
  end
end

# db/migrate/..._create_trip_items.rb
class CreateTripItems < ActiveRecord::Migration[7.1]
  def change
    create_table :trip_items do |t|
      t.references :trip, null: false, foreign_key: true
      t.references :wardrobe_item, null: false, foreign_key: true
      
      # Packing status
      t.boolean :is_packed, default: false
      t.datetime :packed_at
      
      # Notes
      t.text :notes # "Remember to pack this last"
      
      t.timestamps
    end
    
    add_index :trip_items, [:trip_id, :wardrobe_item_id], unique: true
  end
end

# db/migrate/..._create_trip_outfits.rb
class CreateTripOutfits < ActiveRecord::Migration[7.1]
  def change
    create_table :trip_outfits do |t|
      t.references :trip, null: false, foreign_key: true
      
      # Outfit Details
      t.string :occasion # "Day 1 - Arrival", "Evening Dining"
      t.integer :day_number # 1, 2, 3...
      t.string :time_of_day # "morning", "afternoon", "evening"
      
      # Items (stored as array of wardrobe_item_ids)
      t.jsonb :outfit_items # [{wardrobe_item_id: 123, category: "top"}, ...]
      
      # AI Reasoning
      t.text :reasoning # Why this combination works
      
      # User Actions
      t.boolean :is_favorite, default: false
      t.boolean :is_assigned_to_calendar, default: false
      t.date :calendar_date # If assigned
      
      t.timestamps
    end
    
    add_index :trip_outfits, :trip_id
    add_index :trip_outfits, :day_number
  end
end
```

#### Models

```ruby
# app/models/trip.rb
class Trip < ApplicationRecord
  belongs_to :user
  has_many :trip_items, dependent: :destroy
  has_many :wardrobe_items, through: :trip_items
  has_many :trip_outfits, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  
  # Callbacks
  before_save :calculate_duration
  
  # Scopes
  scope :active, -> { where(status: ['planning', 'packed', 'active']) }
  scope :upcoming, -> { where('start_date > ?', Date.today) }
  scope :current, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }
  
  # Calculate trip duration
  def calculate_duration
    self.duration_days = (end_date - start_date).to_i + 1 if start_date && end_date
  end
  
  # Add items to trip
  def add_items(wardrobe_item_ids)
    wardrobe_item_ids.each do |item_id|
      trip_items.create(wardrobe_item_id: item_id)
    end
    update(total_items_packed: trip_items.count)
  end
  
  # Generate outfit combinations
  def generate_outfits
    TripOutfitGenerator.new(self).generate_all_combinations
  end
  
  # Packing progress
  def packing_progress
    return 0 if trip_items.count.zero?
    (trip_items.where(is_packed: true).count.to_f / trip_items.count * 100).round
  end
end
```

#### Services

**Trip Outfit Generator (The Magic Algorithm):**
```ruby
# app/services/trip_outfit_generator.rb
class TripOutfitGenerator
  def initialize(trip)
    @trip = trip
    @items = trip.wardrobe_items.to_a
  end
  
  def generate_all_combinations
    # Step 1: Categorize items
    tops = @items.select { |i| ['top', 'blouse', 'sweater', 'tshirt'].include?(i.category) }
    bottoms = @items.select { |i| ['bottom', 'pants', 'jeans', 'skirt'].include?(i.category) }
    outerwear = @items.select { |i| ['jacket', 'coat', 'blazer'].include?(i.category) }
    shoes = @items.select { |i| i.category == 'shoes' }
    accessories = @items.select { |i| ['accessory', 'scarf', 'bag', 'jewelry'].include?(i.category) }
    
    # Step 2: Generate base combinations (tops × bottoms)
    base_combinations = tops.product(bottoms)
    
    # Step 3: Enhance with layers, shoes, accessories
    all_outfits = []
    
    base_combinations.each do |top, bottom|
      # Option 1: Just top + bottom + shoes
      shoes.each do |shoe|
        outfit = {
          items: [top, bottom, shoe],
          occasion: determine_occasion([top, bottom, shoe]),
          formality: calculate_formality([top, bottom, shoe])
        }
        all_outfits << outfit
      end
      
      # Option 2: Add outerwear
      outerwear.each do |layer|
        shoes.each do |shoe|
          outfit = {
            items: [layer, top, bottom, shoe],
            occasion: determine_occasion([layer, top, bottom, shoe]),
            formality: calculate_formality([layer, top, bottom, shoe])
          }
          all_outfits << outfit
        end
      end
      
      # Option 3: Add accessories (max 2 per outfit)
      accessories.combination(2).each do |acc1, acc2|
        shoes.each do |shoe|
          outfit = {
            items: [top, bottom, shoe, acc1, acc2],
            occasion: determine_occasion([top, bottom, shoe, acc1, acc2]),
            formality: calculate_formality([top, bottom, shoe, acc1, acc2])
          }
          all_outfits << outfit
        end
      end
    end
    
    # Step 4: Filter for quality & variety
    filtered_outfits = filter_outfits(all_outfits)
    
    # Step 5: Assign to trip days
    assign_to_days(filtered_outfits)
    
    # Step 6: Get AI enhancement
    enhance_with_ai_reasoning(filtered_outfits)
    
    # Step 7: Save to database
    save_outfits(filtered_outfits)
    
    filtered_outfits
  end
  
  private
  
  def filter_outfits(outfits)
    # Remove duplicates
    unique_outfits = outfits.uniq { |o| o[:items].map(&:id).sort }
    
    # Remove clashing colors/patterns
    valid_outfits = unique_outfits.reject { |o| has_color_clash?(o[:items]) }
    
    # Sort by formality for variety
    valid_outfits.sort_by { |o| o[:formality] }
  end
  
  def has_color_clash?(items)
    # Simple clash detection (can be enhanced with AI)
    colors = items.map(&:color).compact
    patterns = items.map(&:pattern).compact.reject { |p| p == 'solid' }
    
    # Too many patterns
    return true if patterns.count > 1
    
    # Known clashing colors (very simplified)
    clashing_pairs = [
      ['red', 'pink'],
      ['orange', 'red'],
      ['purple', 'red']
    ]
    
    clashing_pairs.any? do |pair|
      colors.include?(pair[0]) && colors.include?(pair[1])
    end
  end
  
  def determine_occasion(items)
    # AI prompt to determine occasion
    formality = calculate_formality(items)
    
    case formality
    when 0..3 then "Casual Day"
    when 4..6 then "Smart Casual"
    when 7..10 then "Formal Event"
    else "General"
    end
  end
  
  def calculate_formality(items)
    # 0 = very casual, 10 = very formal
    formality_scores = {
      'tshirt' => 0,
      'jeans' => 1,
      'sneakers' => 0,
      'blouse' => 5,
      'trousers' => 6,
      'blazer' => 8,
      'dress shoes' => 7,
      'suit' => 10
    }
    
    items.sum { |item| formality_scores[item.category] || 3 } / items.count
  end
  
  def assign_to_days(outfits)
    # Distribute outfits across trip days
    outfits_per_day = (outfits.count.to_f / @trip.duration_days).ceil
    
    outfits.each_with_index do |outfit, index|
      outfit[:day_number] = (index / outfits_per_day) + 1
    end
  end
  
  def enhance_with_ai_reasoning(outfits)
    # Use Gemini to add reasoning for top 10 outfits
    top_outfits = outfits.first(10)
    
    top_outfits.each do |outfit|
      prompt = <<~PROMPT
        ROLE: Fashion stylist explaining outfit choice
        
        TRIP: #{@trip.name}
        DESTINATION: #{@trip.destination}
        OCCASION: #{outfit[:occasion]}
        
        OUTFIT ITEMS:
        #{outfit[:items].map { |i| "- #{i.category} (#{i.color}, #{i.pattern})" }.join("\n")}
        
        TASK: In 1-2 sentences, explain why this outfit works for this trip/occasion.
        
        EXAMPLE: "This smart casual combination balances comfort for museum walking with enough polish for Parisian cafés. The navy blazer elevates the casual jeans while staying weather-appropriate."
      PROMPT
      
      response = call_gemini_api(prompt)
      outfit[:reasoning] = response
    end
  end
  
  def save_outfits(outfits)
    outfits.each do |outfit_data|
      @trip.trip_outfits.create!(
        occasion: outfit_data[:occasion],
        day_number: outfit_data[:day_number],
        outfit_items: outfit_data[:items].map { |i| 
          { wardrobe_item_id: i.id, category: i.category }
        },
        reasoning: outfit_data[:reasoning]
      )
    end
    
    @trip.update(total_outfits_generated: outfits.count)
  end
end
```

**AI Quick Pack Suggester:**
```ruby
# app/services/trip_packing_suggester.rb
class TripPackingSuggester
  def initialize(trip, user)
    @trip = trip
    @user = user
  end
  
  def suggest_items
    prompt = build_packing_prompt
    response = call_gemini_api(prompt)
    parse_suggestions(response)
  end
  
  private
  
  def build_packing_prompt
    <<~PROMPT
      ROLE: Expert packing consultant
      
      TRIP DETAILS:
      - Destination: #{@trip.destination}
      - Duration: #{@trip.duration_days} days
      - Type: #{@trip.trip_type}
      - Activities: #{@trip.activities.join(', ')}
      - Weather: #{@trip.weather_forecast}
      
      AVAILABLE WARDROBE:
      #{@user.wardrobe_items.active.map { |i| 
        "ID #{i.id}: #{i.category} - #{i.color}, #{i.pattern}, #{i.season_tag}"
      }.join("\n")}
      
      TASK: Suggest optimal packing list
      
      RULES:
      1. Minimize items while maximizing outfit combinations
      2. Account for weather and activities
      3. Suggest 2-3 pairs of shoes max
      4. Include one "nice" outfit for dining
      5. Suggest versatile, mix-and-match pieces
      
      RETURN JSON:
      {
        "recommended_items": [123, 456, 789, ...],
        "essential_additions": ["umbrella", "sunscreen"],
        "outfit_count_estimate": 18,
        "reasoning": "This selection allows 18 outfits from 15 items by focusing on neutral colors that mix well..."
      }
    PROMPT
  end
end
```

### Tier Differentiation

**Free Tier:**
- Create 1 trip
- Generate up to 10 outfit combinations
- Basic packing list

**Premium ($7.99/mo):**
- Create 5 trips
- Generate up to 30 outfit combinations
- AI packing suggestions
- Assign outfits to calendar

**Pro ($14.99/mo):**
- Unlimited trips
- Unlimited outfit combinations
- Advanced packing optimizer (minimize items, maximize outfits)
- Share trip packing list with travel companions
- Export to PDF/print

---

## 📊 Feature Impact Summary

| Feature | Engagement Lift | Retention Impact | Revenue Impact | Development Time |
|---------|----------------|------------------|----------------|------------------|
| **Outfit Calendar** | +40% WAU | +30% D7 retention | Premium upsell driver | 2-3 weeks |
| **Multiple Closets** | +25% items per user | +20% session length | Pro tier differentiator | 2-3 weeks |
| **Trip Planner** | +60% during travel season | +35% quarterly retention | High viral potential | 3-4 weeks |

**Combined Impact:**
- **User engagement**: 2-3x increase in weekly sessions
- **Retention**: 40-50% improvement in 30-day retention
- **Viral growth**: Trip planner has highest share rate (users share packing lists)
- **Revenue**: Strong Premium/Pro upsell justification

---

## 🚀 Recommended Implementation Order

### Option A: Maximize Engagement First
1. **Outfit Calendar** (Week 27-29)
   - Immediate daily engagement boost
   - Low technical complexity
   - Natural progression from existing outfit suggestions

2. **Trip Planner** (Week 30-33)
   - High wow-factor feature
   - Viral potential (social sharing)
   - Leverages calendar feature

3. **Multiple Closets** (Week 34-36)
   - Organization feature
   - Complements trip planner (create trip-specific closets)

### Option B: Build Foundation First
1. **Multiple Closets** (Week 27-29)
   - Foundation for other features
   - Enables trip closets
   - Cleaner data structure

2. **Outfit Calendar** (Week 30-32)
   - Uses closet filtering

3. **Trip Planner** (Week 33-36)
   - Leverages both calendar and closets

**Recommendation**: **Option A** - Users see immediate value from calendar, trip planner creates viral moments, closets refine the experience.

---

## 🎯 Success Metrics

### Outfit Calendar
- **Adoption**: 60% of active users plan ≥1 outfit/week
- **Engagement**: 3x increase in weekly app opens
- **Conversion**: 15% of calendar users upgrade to Premium (for 30-day planning)

### Multiple Closets
- **Adoption**: 40% of users create ≥2 closets
- **Engagement**: 50% more items uploaded (users organize existing + add new)
- **Conversion**: 10% upgrade to Premium for unlimited closets

### Trip Planner
- **Adoption**: 30% of users create ≥1 trip per year
- **Viral**: 25% of trip creators share packing list (social/email)
- **Conversion**: 20% of trip users upgrade to Pro for unlimited combinations

---

## 📝 Technical Notes

### Performance Considerations
- **Trip Outfit Generation**: Can be computationally expensive for large wardrobes
  - Solution: Background job processing (Sidekiq)
  - Show progress indicator ("Generating outfits... 24/28 combinations found")
  - Cache results (regenerate only if items change)

- **Calendar Queries**: Optimize with proper indexing
  - Index on (user_id, scheduled_date)
  - Use eager loading for outfit_suggestions and wardrobe_items

- **Closet Switching**: Avoid N+1 queries
  - Counter cache for items_count
  - Preload wardrobe_items when displaying closet

### AI Cost Management
- **Calendar Suggestions**: ~$0.002 per day planned
- **Trip Outfit Generation**: ~$0.01-0.03 per trip (depending on item count)
- **Packing Suggestions**: ~$0.005 per trip

**Monthly AI Budget** (10,000 MAU):
- Calendar: 10,000 × 4 weeks × 7 days × 30% adoption × $0.002 = **$168/month**
- Trips: 10,000 × 0.5 trips/year ÷ 12 × $0.02 = **$8/month**
- **Total: ~$175/month** (well within budget)

---

## ✅ Implementation Checklist

### Outfit Calendar
- [ ] Database schema (outfit_calendar_entries)
- [ ] Models & associations
- [ ] Calendar UI (week/month/day views)
- [ ] Weather API integration
- [ ] AI suggestion service for calendar events
- [ ] Drag & drop functionality
- [ ] Mobile responsive calendar
- [ ] Export to Google Calendar (Pro feature)

### Multiple Closets
- [ ] Database schema (closets, closet_items)
- [ ] Closet CRUD operations
- [ ] Closet switcher UI
- [ ] Seasonal auto-activation logic (cron job)
- [ ] AI smart fill service
- [ ] Bulk item management
- [ ] Closet sharing (Pro feature)

### Trip Planner
- [ ] Database schema (trips, trip_items, trip_outfits)
- [ ] Trip creation wizard
- [ ] Item selection UI with filters
- [ ] Outfit combination algorithm
- [ ] AI packing suggester service
- [ ] Packing list & checklist
- [ ] Assign outfits to calendar integration
- [ ] PDF export (Pro feature)

---

**This document should be shared with Claude Code to ensure these features are prioritized and implemented according to user expectations.** 🚀
