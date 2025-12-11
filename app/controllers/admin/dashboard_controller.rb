module Admin
  class DashboardController < Admin::BaseController
    def index
      # Overview metrics
      @total_users = User.count
      @paying_users = User.paying_customers.count
      @paying_percentage = @total_users.zero? ? 0 : (@paying_users.to_f / @total_users * 100).round(1)

      # Subscription metrics
      @subscription_metrics = Analytics::SubscriptionMetrics.new
      @mrr = @subscription_metrics.mrr
      @conversion_rates = @subscription_metrics.conversion_rates

      # Usage metrics
      @usage_metrics = Analytics::UsageMetrics.new
      @ai_suggestions_today = @usage_metrics.ai_suggestions_today
      @ai_suggestions_this_month = @usage_metrics.ai_suggestions_this_month
      @estimated_ai_cost = @usage_metrics.estimated_ai_cost_this_month

      # Ad metrics
      @ad_revenue_today = AdImpression.estimated_revenue_today
      @ad_revenue_this_month = AdImpression.estimated_revenue_this_month

      # Recent activity
      @recent_users = User.recent.limit(5)
      @recent_suggestions = OutfitSuggestion.recent.includes(:user).limit(10)

      # User tier breakdown
      @users_by_tier = {
        free: User.free_tier.count,
        premium: User.premium_tier.count,
        pro: User.pro_tier.count
      }

      # Activity metrics
      @active_users_last_30_days = User.active_last_30_days.count
    end
  end
end
