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
      @ai_cost_this_month = @estimated_ai_cost # Alias for view compatibility

      # Ad metrics
      @ad_revenue_today = AdImpression.estimated_revenue_today
      @ad_revenue_this_month = AdImpression.estimated_revenue_this_month

      # Recent activity
      @recent_users = User.recent.limit(5)
      @recent_suggestions = OutfitSuggestion.recent.includes(:user).limit(10)

      # Build recent activities feed
      @recent_activities = []
      @recent_users.each do |user|
        @recent_activities << {
          type: 'user_signup',
          user: user,
          time: user.created_at,
          color: 'from-blue-600 to-blue-400',
          icon: 'user',
          text: "#{user.email} signed up"
        }
      end
      @recent_suggestions.first(5).each do |suggestion|
        @recent_activities << {
          type: 'ai_suggestion',
          user: suggestion.user,
          time: suggestion.created_at,
          color: 'from-purple-600 to-pink-400',
          icon: 'sparkles',
          text: "#{suggestion.user.email} got AI suggestion"
        }
      end
      @recent_activities = @recent_activities.sort_by { |a| a[:time] }.reverse.first(10)

      # User tier breakdown
      @users_by_tier = {
        free: User.free_tier.count,
        premium: User.premium_tier.count,
        pro: User.pro_tier.count
      }

      # Activity metrics
      @active_users_last_30_days = User.active_last_30_days.count
      @new_users_this_week = User.where('created_at >= ?', 1.week.ago).count
    end
  end
end
