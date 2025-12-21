class ProductRecommendation < ApplicationRecord
  # Associations
  belongs_to :outfit_suggestion

  # Enums using integer columns (following existing codebase pattern)
  enum priority: {
    low: 0,
    medium: 1,
    high: 2
  }

  enum budget_range: {
    budget: 0,
    mid_range: 1,
    premium: 2,
    luxury: 3
  }

  enum ai_image_status: {
    pending: 0,
    generating: 1,
    completed: 2,
    failed: 3
  }

  # Validations
  validates :category, presence: true
  validates :priority, presence: true
  validates :budget_range, presence: true
  validates :ai_image_status, presence: true
  validates :views, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :clicks, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :conversions, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :revenue_earned, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :high_priority, -> { where(priority: :high) }
  scope :with_images, -> { where(ai_image_status: :completed) }
  scope :with_products, -> { where("jsonb_array_length(affiliate_products) > 0") }
  scope :most_clicked, -> { order(clicks: :desc) }
  scope :best_ctr, -> { where("views > 0").order(Arel.sql("CAST(clicks AS FLOAT) / NULLIF(views, 0) DESC")) }
  scope :best_conversion_rate, -> { where("clicks > 0").order(Arel.sql("CAST(conversions AS FLOAT) / NULLIF(clicks, 0) DESC")) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }

  # Helper methods for AI image generation
  def mark_image_generating!
    update!(
      ai_image_status: :generating,
      ai_image_error: nil
    )
  end

  def mark_image_completed!(image_url, cost = 0.0)
    update!(
      ai_image_status: :completed,
      ai_image_url: image_url,
      ai_image_cost: cost,
      ai_image_error: nil
    )
  end

  def mark_image_failed!(error_message)
    update!(
      ai_image_status: :failed,
      ai_image_error: error_message
    )
  end

  # Analytics helper methods
  def ctr
    return 0.0 if views.zero?
    (clicks.to_f / views * 100).round(2)
  end

  def conversion_rate
    return 0.0 if clicks.zero?
    (conversions.to_f / clicks * 100).round(2)
  end

  def avg_revenue_per_conversion
    return 0.0 if conversions.zero?
    (revenue_earned / conversions).round(2)
  end

  # Increment analytics counters
  def record_view!
    increment!(:views)
  end

  def record_click!
    increment!(:clicks)
  end

  def record_conversion!(revenue = 0.0)
    self.conversions += 1
    self.revenue_earned = (self.revenue_earned || 0) + revenue
    save!
  end

  # Product management helpers
  def has_products?
    affiliate_products.present? && affiliate_products.any?
  end

  def products_count
    affiliate_products&.size || 0
  end

  def add_affiliate_product(product_data)
    self.affiliate_products ||= []
    self.affiliate_products << product_data
    save!
  end

  def clear_affiliate_products!
    update!(affiliate_products: [])
  end
end
