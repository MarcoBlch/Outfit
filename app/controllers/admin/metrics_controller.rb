module Admin
  class MetricsController < Admin::BaseController
    def subscriptions
      @subscription_metrics = Analytics::SubscriptionMetrics.new

      # Revenue metrics
      @mrr = @subscription_metrics.mrr
      @mrr_breakdown = @subscription_metrics.mrr_breakdown
      @total_paying_customers = @subscription_metrics.total_paying_customers
      @conversion_rates = @subscription_metrics.conversion_rates
      @arpu = @subscription_metrics.arpu

      # Subscription health
      @active_subscriptions = @subscription_metrics.active_subscriptions_by_tier
      @new_subscriptions_this_month = @subscription_metrics.new_subscriptions_this_month
      @cancellations_this_month = @subscription_metrics.cancellations_this_month
      @churn_rate = @subscription_metrics.churn_rate
      @reactivations_this_month = @subscription_metrics.reactivations_this_month

      # Historical data for charts
      @mrr_over_time = @subscription_metrics.mrr_over_time(90)
      @signups_by_week = @subscription_metrics.signups_by_week(12)
      @tier_distribution = @subscription_metrics.tier_distribution

      # Cohort analysis
      @retention_cohorts = @subscription_metrics.retention_cohorts if params[:show_cohorts]
    end

    def usage
      @usage_metrics = Analytics::UsageMetrics.new

      # AI usage stats
      @ai_stats = @usage_metrics.ai_suggestions_stats
      @suggestions_over_time = @usage_metrics.suggestions_over_time(30)
      @avg_per_user = @usage_metrics.avg_suggestions_per_user

      # API costs
      @estimated_cost_today = @usage_metrics.estimated_ai_cost_today
      @estimated_cost_this_month = @usage_metrics.estimated_ai_cost_this_month
      @cost_by_tier = @usage_metrics.cost_by_tier

      # Feature usage
      @image_searches_count = @usage_metrics.image_searches_this_month
      @outfits_created = @usage_metrics.outfits_created_this_month
      @wardrobe_items_uploaded = @usage_metrics.wardrobe_items_uploaded_this_month

      # Top contexts
      @top_contexts = @usage_metrics.top_contexts(10)

      # Peak usage times
      @usage_by_hour = @usage_metrics.usage_by_hour if params[:show_heatmap]

      # Ad metrics
      @ad_impressions_today = AdImpression.today.count
      @ad_impressions_this_month = AdImpression.this_month.count
      @ad_revenue_this_month = AdImpression.estimated_revenue_this_month
      @ad_ctr = AdImpression.click_through_rate(:this_month)
      @ad_revenue_by_placement = AdImpression.revenue_by_placement
    end
  end
end
