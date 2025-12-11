module Analytics
  class SubscriptionMetrics
    # Pricing constants
    PREMIUM_PRICE = 7.99
    PRO_PRICE = 14.99

    # Monthly Recurring Revenue
    def mrr
      {
        total: calculate_total_mrr,
        premium: User.premium_tier.count * PREMIUM_PRICE,
        pro: User.pro_tier.count * PRO_PRICE
      }
    end

    def mrr_breakdown
      {
        premium: {
          count: User.premium_tier.count,
          price: PREMIUM_PRICE,
          total: User.premium_tier.count * PREMIUM_PRICE
        },
        pro: {
          count: User.pro_tier.count,
          price: PRO_PRICE,
          total: User.pro_tier.count * PRO_PRICE
        }
      }
    end

    def total_paying_customers
      User.paying_customers.count
    end

    # Conversion rates
    def conversion_rates
      total_users = User.count
      return { free_to_premium: 0, premium_to_pro: 0, free_to_paying: 0 } if total_users.zero?

      premium_count = User.premium_tier.count
      pro_count = User.pro_tier.count
      paying_count = premium_count + pro_count

      {
        free_to_paying: (paying_count.to_f / total_users * 100).round(2),
        free_to_premium: (premium_count.to_f / total_users * 100).round(2),
        premium_to_pro: paying_count.zero? ? 0 : (pro_count.to_f / paying_count * 100).round(2)
      }
    end

    # Average Revenue Per User
    def arpu
      total_users = User.count
      return 0 if total_users.zero?

      (calculate_total_mrr / total_users).round(2)
    end

    # Active subscriptions by tier
    def active_subscriptions_by_tier
      {
        free: User.free_tier.count,
        premium: User.premium_tier.count,
        pro: User.pro_tier.count
      }
    end

    # Tier distribution (for pie charts)
    def tier_distribution
      total = User.count
      return {} if total.zero?

      {
        "Free" => User.free_tier.count,
        "Premium" => User.premium_tier.count,
        "Pro" => User.pro_tier.count
      }
    end

    # New subscriptions this month
    def new_subscriptions_this_month
      # Count users who upgraded from free to premium/pro this month
      # This is a simplified version - in production, you'd track this via Stripe webhooks
      User.paying_customers.where("created_at >= ?", 1.month.ago).count
    end

    # Cancellations this month
    def cancellations_this_month
      # Count active subscriptions that were cancelled this month
      # In production, this would come from Stripe webhook events
      Subscription.where(status: "canceled")
                  .where("updated_at >= ?", 1.month.ago)
                  .count
    end

    # Churn rate (monthly)
    def churn_rate(period: 1.month)
      start_of_period = period.ago.beginning_of_month
      end_of_period = period.ago.end_of_month

      paying_at_start = User.where("subscription_tier IN (?) AND created_at <= ?",
                                   ["premium", "pro"], start_of_period).count

      return 0 if paying_at_start.zero?

      # Simplified churn calculation
      # In production, track downgrades and cancellations via Stripe webhooks
      churned = cancellations_this_month

      (churned.to_f / paying_at_start * 100).round(2)
    end

    # Reactivations (users who came back from free to paying)
    def reactivations_this_month
      # This would be tracked via subscription state changes in production
      # Simplified: count users who are paying now but were free before
      0 # Placeholder - implement with proper subscription history tracking
    end

    # MRR over time (for line charts)
    def mrr_over_time(days = 90)
      # Group users by signup date and calculate MRR
      # This is a simplified version showing cumulative MRR growth
      User.where("created_at >= ?", days.days.ago)
          .where(subscription_tier: ["premium", "pro"])
          .group_by_day(:created_at)
          .count
          .transform_values { |count| count * PREMIUM_PRICE } # Simplified
    end

    # Signups by week
    def signups_by_week(weeks = 12)
      User.where("created_at >= ?", weeks.weeks.ago)
          .group_by_week(:created_at)
          .count
    end

    # Retention cohorts (Day 7, 30, 90 retention)
    def retention_cohorts
      # This is a complex calculation that would require proper tracking
      # Placeholder for future implementation
      {
        day_7: calculate_retention(7.days),
        day_30: calculate_retention(30.days),
        day_90: calculate_retention(90.days)
      }
    end

    private

    def calculate_total_mrr
      (User.premium_tier.count * PREMIUM_PRICE) + (User.pro_tier.count * PRO_PRICE)
    end

    def calculate_retention(period)
      # Calculate what percentage of users who signed up `period` ago are still active
      signup_date = period.ago.to_date
      cohort_users = User.where(created_at: signup_date.beginning_of_day..signup_date.end_of_day)
      return 0 if cohort_users.count.zero?

      active_users = cohort_users.where("updated_at >= ?", 7.days.ago).count
      ((active_users.to_f / cohort_users.count) * 100).round(2)
    end
  end
end
