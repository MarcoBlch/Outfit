class User < ApplicationRecord
  has_many :wardrobe_items, dependent: :destroy
  has_many :outfits, dependent: :destroy
  has_many :outfit_suggestions, dependent: :destroy
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
end
