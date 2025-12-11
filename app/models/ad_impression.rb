class AdImpression < ApplicationRecord
  belongs_to :user

  # Validations
  validates :placement, presence: true,
                        inclusion: { in: %w[dashboard_banner wardrobe_grid outfit_modal sidebar footer] }
  validates :clicked, inclusion: { in: [true, false] }
  validates :revenue, numericality: { greater_than_or_equal_to: 0 }

  # Scopes for time-based analytics
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
  scope :date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Scopes for analytics queries
  scope :clicked, -> { where(clicked: true) }
  scope :not_clicked, -> { where(clicked: false) }
  scope :by_placement, ->(placement) { where(placement: placement) }
  scope :by_network, ->(network) { where(ad_network: network) }

  # Order scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }

  # Analytics methods

  # Calculate total revenue for a given scope
  # @return [BigDecimal] Total revenue
  def self.total_revenue
    sum(:revenue)
  end

  # Calculate click-through rate (CTR) as a percentage
  # @return [Float] CTR percentage (0-100)
  def self.click_through_rate
    return 0.0 if count.zero?
    (clicked.count.to_f / count * 100).round(2)
  end

  # Calculate estimated revenue per impression (RPM - Revenue Per Mille)
  # @return [Float] Revenue per 1000 impressions
  def self.revenue_per_mille
    return 0.0 if count.zero?
    (total_revenue / count * 1000).to_f.round(2)
  end

  # Get revenue breakdown by placement
  # @return [Hash] Placement => revenue hash
  def self.revenue_by_placement
    group(:placement).sum(:revenue)
  end

  # Get impression count by placement
  # @return [Hash] Placement => count hash
  def self.impressions_by_placement
    group(:placement).count
  end

  # Get CTR by placement
  # @return [Hash] Placement => CTR hash
  def self.ctr_by_placement
    select('placement,
            COUNT(*) AS total_impressions,
            COUNT(*) FILTER (WHERE clicked = true) AS total_clicks,
            ROUND(COUNT(*) FILTER (WHERE clicked = true) * 100.0 / COUNT(*), 2) AS ctr')
      .group(:placement)
      .map { |record| [record.placement, record.ctr.to_f] }
      .to_h
  end

  # Get daily revenue for the last N days
  # @param days [Integer] Number of days to look back
  # @return [Hash] Date => revenue hash
  def self.daily_revenue(days: 30)
    where('created_at >= ?', days.days.ago)
      .group("DATE(created_at)")
      .sum(:revenue)
      .transform_keys { |date| Date.parse(date.to_s) }
  end

  # Get daily impression count for the last N days
  # @param days [Integer] Number of days to look back
  # @return [Hash] Date => count hash
  def self.daily_impressions(days: 30)
    where('created_at >= ?', days.days.ago)
      .group("DATE(created_at)")
      .count
      .transform_keys { |date| Date.parse(date.to_s) }
  end

  # Estimate revenue for a single impression based on CPM
  # @param cpm [Float] Cost per mille (per 1000 impressions)
  # @return [Float] Estimated revenue for this impression
  def self.calculate_revenue_from_cpm(cpm)
    (cpm / 1000.0).round(6)
  end

  # Record an ad impression
  # @param user [User] User who saw the ad
  # @param placement [String] Where the ad was shown
  # @param options [Hash] Optional parameters
  # @return [AdImpression] Created impression record
  def self.record_impression(user, placement, **options)
    create!(
      user: user,
      placement: placement,
      clicked: options[:clicked] || false,
      revenue: options[:revenue] || calculate_revenue_from_cpm(options[:cpm] || 2.0),
      ad_network: options[:ad_network] || 'google_adsense',
      ad_unit_id: options[:ad_unit_id],
      ip_address: options[:ip_address],
      user_agent: options[:user_agent]
    )
  end

  # Record a click on an existing impression
  # @return [Boolean] Whether the click was recorded
  def record_click!
    return false if clicked? # Already clicked

    update!(clicked: true)
  end
end
