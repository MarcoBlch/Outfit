class User < ApplicationRecord
  # Explicitly set primary key to avoid any inference issues
  self.primary_key = 'id'

  # Include Devise modules FIRST, then JWT strategy
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable are available but not used
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self,
         authentication_keys: [:email]

  # JTIMatcher must be included AFTER devise call
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Ensure proper primary key for JWT lookups
  def self.find_for_jwt_authentication(sub)
    find_by(id: sub)
  end

  # Validations
  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" },
            length: { minimum: 3, maximum: 30 }

  # Generate username from email before validation if not provided
  before_validation :generate_username, on: :create, if: -> { username.blank? }

  has_many :wardrobe_items, dependent: :destroy
  has_many :outfits, dependent: :destroy
  has_many :outfit_suggestions, dependent: :destroy
  has_many :ad_impressions, dependent: :destroy
  has_one :user_profile, dependent: :destroy
  has_one :subscription, dependent: :destroy

  # Scopes for admin dashboard queries
  scope :admins, -> { where(admin: true) }
  scope :non_admins, -> { where(admin: false) }

  # Subscription tier scopes
  scope :free_tier, -> { where(subscription_tier: 'free') }
  scope :premium_tier, -> { where(subscription_tier: 'premium') }
  scope :pro_tier, -> { where(subscription_tier: 'pro') }
  scope :paying, -> { where(subscription_tier: ['premium', 'pro']) }

  # Activity scopes
  scope :active, -> { joins(:outfit_suggestions).where('outfit_suggestions.created_at >= ?', 7.days.ago).distinct }
  scope :inactive, -> {
    left_joins(:outfit_suggestions)
      .where('outfit_suggestions.created_at < ? OR outfit_suggestions.id IS NULL', 30.days.ago)
      .distinct
  }
  scope :recent_signups, ->(days = 7) { where('users.created_at >= ?', days.days.ago) }
  scope :by_signup_date, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Ordering scopes
  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  # AI Outfit Suggestions - Rate Limiting
  def remaining_suggestions_today
    limit = case subscription_tier
    when "pro" then 100
    when "premium" then 30
    else 3
    end

    # Use Redis cache to match the rate limiting in OutfitSuggestionService
    today = Date.current
    usage_key = "outfit_suggestions:#{id}:#{today}"
    used = Rails.cache.read(usage_key) || 0

    [limit - used, 0].max
  end

  def can_request_suggestion?
    remaining_suggestions_today > 0
  end

  def premium?
    subscription_tier == "premium" || subscription_tier == "pro"
  end

  def pro?
    subscription_tier == "pro"
  end

  def free_tier?
    subscription_tier == "free" || subscription_tier.blank?
  end

  # Admin helpers
  def admin?
    admin == true
  end

  def make_admin!
    update!(admin: true)
  end

  def revoke_admin!
    update!(admin: false)
  end

  # Subscription helpers
  def active_subscription?
    subscription&.active_subscription?
  end

  def subscription_status
    return "none" unless subscription.present?
    subscription.status
  end

  def subscription_ends_at
    subscription&.current_period_end
  end

  # Wardrobe item limits based on subscription
  def wardrobe_item_limit
    premium? ? 300 : 50
  end

  def can_add_wardrobe_item?
    wardrobe_items.count < wardrobe_item_limit
  end

  def wardrobe_items_remaining
    [wardrobe_item_limit - wardrobe_items.count, 0].max
  end

  # Image search limits (Premium only)
  def image_searches_per_day
    premium? ? 5 : 0
  end

  def remaining_image_searches_today
    return 0 unless premium?

    today = Date.current
    usage_key = "image_searches:#{id}:#{today}"
    used = Rails.cache.read(usage_key) || 0

    [image_searches_per_day - used, 0].max
  end

  def can_search_images?
    remaining_image_searches_today > 0
  end

  def record_image_search!
    return false unless can_search_images?

    today = Date.current
    usage_key = "image_searches:#{id}:#{today}"
    current_count = Rails.cache.read(usage_key) || 0
    Rails.cache.write(usage_key, current_count + 1, expires_in: 24.hours)
    true
  end

  # Weather Integration (uses location from user_profile)
  def weather_available?
    user_profile&.location.present? && ENV["OPENWEATHER_API_KEY"].present?
  end

  def current_weather
    return nil unless weather_available?

    WeatherService.new(user_profile.location).current_conditions
  end

  # Last activity tracking (proxy for Devise trackable)
  def current_sign_in_at
    # Since trackable is not enabled, use updated_at as proxy for last activity
    outfit_suggestions.maximum(:created_at) || updated_at
  end

  # Admin access
  def admin?
    admin == true
  end

  # Scopes for admin queries
  scope :admins, -> { where(admin: true) }
  scope :premium_tier, -> { where(subscription_tier: "premium") }
  scope :pro_tier, -> { where(subscription_tier: "pro") }
  scope :free_tier, -> { where(subscription_tier: "free").or(where(subscription_tier: nil)) }
  scope :paying_customers, -> { where(subscription_tier: ["premium", "pro"]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active_last_30_days, -> { where("updated_at >= ?", 30.days.ago) }

  private

  def generate_username
    # Extract username from email (before @)
    base_username = email.split('@').first.gsub(/[^a-zA-Z0-9_]/, '_')

    # Ensure it's at least 3 characters
    base_username = "user_#{base_username}" if base_username.length < 3

    # Make it unique by adding numbers if needed
    potential_username = base_username
    counter = 1

    while User.exists?(username: potential_username)
      potential_username = "#{base_username}#{counter}"
      counter += 1
    end

    self.username = potential_username
  end
end
