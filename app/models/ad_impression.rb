class AdImpression < ApplicationRecord
  belongs_to :user

  # Validations
  validates :placement, presence: true,
            inclusion: { in: %w[dashboard_banner wardrobe_grid outfit_modal] }
  validates :clicked, inclusion: { in: [true, false] }
  validates :revenue, numericality: { greater_than_or_equal_to: 0 }

  # Scopes for analytics
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }
  scope :this_week, -> { where("created_at >= ?", 1.week.ago) }
  scope :this_month, -> { where("created_at >= ?", 1.month.ago) }
  scope :clicked, -> { where(clicked: true) }
  scope :by_placement, ->(placement) { where(placement: placement) }

  # Analytics methods
  def self.estimated_revenue_today
    today.sum(:revenue)
  end

  def self.estimated_revenue_this_month
    this_month.sum(:revenue)
  end

  def self.click_through_rate(period = :today)
    scope = send(period)
    total = scope.count
    return 0 if total.zero?

    (scope.clicked.count.to_f / total * 100).round(2)
  end

  def self.revenue_by_placement
    group(:placement).sum(:revenue)
  end

  def self.impressions_by_day(days = 30)
    where("created_at >= ?", days.days.ago)
      .group_by_day(:created_at)
      .count
  end
end
