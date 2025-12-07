class User < ApplicationRecord
  has_many :wardrobe_items, dependent: :destroy
  has_many :outfits, dependent: :destroy
  has_many :outfit_suggestions, dependent: :destroy
  has_one :user_profile, dependent: :destroy
  has_one :subscription, dependent: :destroy
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

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

  def free_tier?
    subscription_tier == "free" || subscription_tier.blank?
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
end
