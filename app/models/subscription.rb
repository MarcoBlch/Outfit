class Subscription < ApplicationRecord
  belongs_to :user

  enum status: {
    active: 0,
    canceled: 1,
    past_due: 2,
    trialing: 3,
    incomplete: 4
  }

  validates :user_id, uniqueness: true
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  scope :active_or_trialing, -> { where(status: [:active, :trialing]) }

  def active_subscription?
    active? || trialing?
  end

  def days_remaining
    return 0 unless current_period_end.present?
    [(current_period_end.to_date - Date.current).to_i, 0].max
  end

  def will_cancel?
    cancel_at_period_end?
  end

  def sync_with_stripe!
    return unless stripe_subscription_id.present?

    stripe_sub = Stripe::Subscription.retrieve(stripe_subscription_id)
    update!(
      status: stripe_sub.status,
      current_period_start: Time.zone.at(stripe_sub.current_period_start),
      current_period_end: Time.zone.at(stripe_sub.current_period_end),
      cancel_at_period_end: stripe_sub.cancel_at_period_end
    )
  rescue Stripe::StripeError => e
    Rails.logger.error("Failed to sync subscription #{id}: #{e.message}")
    false
  end
end
