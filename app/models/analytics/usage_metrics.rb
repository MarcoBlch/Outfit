module Analytics
  class UsageMetrics
    # AI suggestion costs (estimated)
    GEMINI_COST_PER_CALL = 0.01

    # AI Suggestions Stats
    def ai_suggestions_stats
      {
        total_today: OutfitSuggestion.today.count,
        total_this_week: OutfitSuggestion.this_week.count,
        total_this_month: OutfitSuggestion.this_month.count,
        total_all_time: OutfitSuggestion.count
      }
    end

    def ai_suggestions_today
      OutfitSuggestion.today.count
    end

    def ai_suggestions_this_week
      OutfitSuggestion.this_week.count
    end

    def ai_suggestions_this_month
      OutfitSuggestion.this_month.count
    end

    # Average suggestions per user
    def avg_suggestions_per_user
      total_users = User.count
      return 0 if total_users.zero?

      (OutfitSuggestion.count.to_f / total_users).round(2)
    end

    # Suggestions over time (for line charts)
    def suggestions_over_time(days = 30)
      OutfitSuggestion.where("created_at >= ?", days.days.ago)
                     .group_by_day(:created_at)
                     .count
    end

    # API Cost calculations
    def estimated_ai_cost_today
      # Use actual api_cost column if available, otherwise estimate
      if OutfitSuggestion.column_names.include?("api_cost")
        OutfitSuggestion.today.sum(:api_cost)
      else
        OutfitSuggestion.today.count * GEMINI_COST_PER_CALL
      end
    end

    def estimated_ai_cost_this_week
      if OutfitSuggestion.column_names.include?("api_cost")
        OutfitSuggestion.this_week.sum(:api_cost)
      else
        OutfitSuggestion.this_week.count * GEMINI_COST_PER_CALL
      end
    end

    def estimated_ai_cost_this_month
      if OutfitSuggestion.column_names.include?("api_cost")
        OutfitSuggestion.this_month.sum(:api_cost)
      else
        OutfitSuggestion.this_month.count * GEMINI_COST_PER_CALL
      end
    end

    # Cost breakdown by tier
    def cost_by_tier
      {
        free: cost_for_tier("free"),
        premium: cost_for_tier("premium"),
        pro: cost_for_tier("pro")
      }
    end

    # Top contexts (most popular outfit contexts)
    def top_contexts(limit = 10)
      OutfitSuggestion.where("context IS NOT NULL AND context != ''")
                     .group(:context)
                     .count
                     .sort_by { |_, count| -count }
                     .first(limit)
                     .to_h
    end

    # Peak usage times (hour of day)
    def usage_by_hour
      # Get hour from created_at and group by it
      OutfitSuggestion.this_month
                     .group("EXTRACT(HOUR FROM created_at)")
                     .count
                     .sort
                     .to_h
    end

    # Feature usage: Image searches (Premium+)
    def image_searches_this_month
      # This would require tracking image searches separately
      # Placeholder - implement when image search tracking is added
      0
    end

    # Feature usage: Outfits created
    def outfits_created_today
      Outfit.where("created_at >= ?", Time.current.beginning_of_day).count
    end

    def outfits_created_this_week
      Outfit.where("created_at >= ?", 1.week.ago).count
    end

    def outfits_created_this_month
      Outfit.where("created_at >= ?", 1.month.ago).count
    end

    # Feature usage: Wardrobe items uploaded
    def wardrobe_items_uploaded_today
      WardrobeItem.where("created_at >= ?", Time.current.beginning_of_day).count
    end

    def wardrobe_items_uploaded_this_week
      WardrobeItem.where("created_at >= ?", 1.week.ago).count
    end

    def wardrobe_items_uploaded_this_month
      WardrobeItem.where("created_at >= ?", 1.month.ago).count
    end

    # Success rate for AI suggestions
    def suggestion_success_rate
      total = OutfitSuggestion.count
      return 0 if total.zero?

      completed = OutfitSuggestion.completed.count
      ((completed.to_f / total) * 100).round(2)
    end

    # Average response time for AI suggestions
    def avg_response_time
      # If response_time_ms column exists
      if OutfitSuggestion.column_names.include?("response_time_ms")
        avg = OutfitSuggestion.where("response_time_ms IS NOT NULL")
                             .average(:response_time_ms)
        avg ? avg.round(2) : 0
      else
        0
      end
    end

    # Most active users (by suggestions generated)
    def most_active_users(limit = 10)
      User.joins(:outfit_suggestions)
          .group("users.id")
          .select("users.*, COUNT(outfit_suggestions.id) as suggestions_count")
          .order("suggestions_count DESC")
          .limit(limit)
    end

    # Users by engagement level
    def users_by_engagement
      {
        highly_engaged: User.joins(:outfit_suggestions)
                           .group("users.id")
                           .having("COUNT(outfit_suggestions.id) >= 10")
                           .count.size,
        moderately_engaged: User.joins(:outfit_suggestions)
                               .group("users.id")
                               .having("COUNT(outfit_suggestions.id) BETWEEN 3 AND 9")
                               .count.size,
        low_engaged: User.joins(:outfit_suggestions)
                        .group("users.id")
                        .having("COUNT(outfit_suggestions.id) BETWEEN 1 AND 2")
                        .count.size,
        not_engaged: User.left_joins(:outfit_suggestions)
                        .group("users.id")
                        .having("COUNT(outfit_suggestions.id) = 0")
                        .count.size
      }
    end

    private

    def cost_for_tier(tier)
      user_ids = case tier
                 when "free"
                   User.free_tier.pluck(:id)
                 when "premium"
                   User.premium_tier.pluck(:id)
                 when "pro"
                   User.pro_tier.pluck(:id)
                 else
                   []
                 end

      return 0 if user_ids.empty?

      if OutfitSuggestion.column_names.include?("api_cost")
        OutfitSuggestion.where(user_id: user_ids).this_month.sum(:api_cost)
      else
        OutfitSuggestion.where(user_id: user_ids).this_month.count * GEMINI_COST_PER_CALL
      end
    end
  end
end
