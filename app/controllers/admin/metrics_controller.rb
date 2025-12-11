module Admin
  class MetricsController < Admin::BaseController
    def subscriptions
      @subscription_metrics = Analytics::SubscriptionMetrics.new

      # Revenue metrics
      @total_mrr = @subscription_metrics.mrr
      @mrr_breakdown = @subscription_metrics.mrr_breakdown
      @premium_mrr = @mrr_breakdown[:premium] || 0
      @pro_mrr = @mrr_breakdown[:pro] || 0
      @total_paying_customers = @subscription_metrics.total_paying_customers
      @conversion_rates = @subscription_metrics.conversion_rates
      @arpu = @subscription_metrics.arpu

      # MRR Growth
      @mrr_trend = @subscription_metrics.mrr_over_time(30).values
      @mrr_growth_percentage = if @mrr_trend.length >= 2 && @mrr_trend[-2] > 0
        ((@mrr_trend.last - @mrr_trend[-2]) / @mrr_trend[-2] * 100).round(1)
      else
        0.0
      end

      # User counts
      @total_users = User.count
      @premium_count = User.premium_tier.count
      @pro_count = User.pro_tier.count

      # Conversion rates
      @conversion_rate = @total_users > 0 ? ((@premium_count + @pro_count).to_f / @total_users * 100).round(1) : 0.0
      @premium_conversion_rate = @total_users > 0 ? (@premium_count.to_f / @total_users * 100).round(1) : 0.0
      @pro_conversion_rate = @total_users > 0 ? (@pro_count.to_f / @total_users * 100).round(1) : 0.0

      # Profile completion
      @users_with_profile = User.joins(:user_profile).count
      @profile_completion_rate = @total_users > 0 ? (@users_with_profile.to_f / @total_users * 100).round(1) : 0.0

      # Subscription health
      @active_subscriptions = @subscription_metrics.active_subscriptions_by_tier
      @new_subscriptions_this_month = @subscription_metrics.new_subscriptions_this_month
      @cancellations_this_month = @subscription_metrics.cancellations_this_month
      @churn_rate = @subscription_metrics.churn_rate
      @reactivations_this_month = @subscription_metrics.reactivations_this_month

      # Recent events
      @recent_subscription_events = []
      User.where.not(subscription_tier: 'free').order(updated_at: :desc).limit(10).each do |user|
        @recent_subscription_events << {
          user: user,
          tier: user.subscription_tier,
          time: user.updated_at
        }
      end

      # Distribution
      @subscriber_distribution = {
        premium: @premium_count,
        pro: @pro_count
      }

      # Historical data for charts
      @mrr_over_time = @subscription_metrics.mrr_over_time(90)
      @signups_by_week = @subscription_metrics.signups_by_week(12)
      @tier_distribution = @subscription_metrics.tier_distribution

      # Cohort analysis
      @cohort_data = []
      @retention_cohorts = @subscription_metrics.retention_cohorts if params[:show_cohorts]
    end

    def usage
      @usage_metrics = Analytics::UsageMetrics.new

      # AI usage stats
      @suggestions_today = @usage_metrics.ai_suggestions_today
      @suggestions_this_month = @usage_metrics.ai_suggestions_this_month
      @total_suggestions = OutfitSuggestion.count
      @suggestions_over_time = @usage_metrics.suggestions_over_time(30)
      @avg_suggestions_per_user = @usage_metrics.avg_suggestions_per_user

      # API costs
      @estimated_cost_today = @usage_metrics.estimated_ai_cost_today
      @ai_cost_this_month = @usage_metrics.estimated_ai_cost_this_month
      @ai_costs_over_time = (0..29).map do |days_ago|
        date = days_ago.days.ago.to_date
        cost = OutfitSuggestion.where(created_at: date.beginning_of_day..date.end_of_day).count * 0.002
        [date.strftime("%b %d"), cost.round(2)]
      end.reverse.to_h

      # Usage by tier
      @usage_by_tier = {
        free: OutfitSuggestion.joins(:user).where(users: { subscription_tier: 'free' }).where('outfit_suggestions.created_at >= ?', 30.days.ago).count,
        premium: OutfitSuggestion.joins(:user).where(users: { subscription_tier: 'premium' }).where('outfit_suggestions.created_at >= ?', 30.days.ago).count,
        pro: OutfitSuggestion.joins(:user).where(users: { subscription_tier: 'pro' }).where('outfit_suggestions.created_at >= ?', 30.days.ago).count
      }

      # Feature usage
      @total_image_searches = WardrobeSearch.count rescue 0
      @total_outfits = Outfit.count
      @outfits_this_week = Outfit.where('created_at >= ?', 1.week.ago).count
      @total_wardrobe_items = WardrobeItem.count
      @wardrobe_items_this_week = WardrobeItem.where('created_at >= ?', 1.week.ago).count

      # Active users
      @daily_active_users = User.where('updated_at >= ?', 1.day.ago).count

      # Top contexts (most common outfit contexts)
      @top_contexts = OutfitSuggestion.where.not(context: nil)
                                     .where('created_at >= ?', 30.days.ago)
                                     .group(:context)
                                     .order('count_all DESC')
                                     .limit(10)
                                     .count

      # Peak usage times
      @hourly_usage = (0..23).map do |hour|
        count = OutfitSuggestion.where('EXTRACT(HOUR FROM created_at) = ?', hour)
                                .where('created_at >= ?', 7.days.ago)
                                .count
        [hour, count]
      end.to_h

      # Ad metrics (if AdImpression model exists)
      begin
        @ad_impressions_today = AdImpression.where('created_at >= ?', Date.current.beginning_of_day).count
        @ad_impressions_this_month = AdImpression.where('created_at >= ?', Date.current.beginning_of_month).count
        @ad_revenue_this_month = AdImpression.estimated_revenue_this_month
        @ad_ctr = AdImpression.click_through_rate(:this_month) rescue 0
        @ad_revenue_by_placement = AdImpression.revenue_by_placement rescue {}
      rescue NameError
        @ad_impressions_today = 0
        @ad_impressions_this_month = 0
        @ad_revenue_this_month = 0
        @ad_ctr = 0
        @ad_revenue_by_placement = {}
      end
    end
  end
end
