module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :update_tier]

    def index
      @users = User.left_joins(:wardrobe_items, :outfits, :outfit_suggestions)
                   .select("users.*,
                            COUNT(DISTINCT wardrobe_items.id) AS wardrobe_items_count,
                            COUNT(DISTINCT outfits.id) AS outfits_count,
                            COUNT(DISTINCT outfit_suggestions.id) AS outfit_suggestions_count,
                            MAX(outfit_suggestions.created_at) AS last_activity_at")
                   .group("users.id")
                   .order(created_at: :desc)

      # Apply filters
      @users = apply_filters(@users)

      # Search by email
      if params[:search].present?
        @users = @users.where("email ILIKE ?", "%#{params[:search]}%")
      end

      # Pagination
      @users = @users.page(params[:page]).per(50)

      # Stats for the filtered set (use the base query before pagination)
      base_query = User.all
      base_query = apply_filters(base_query) if params[:tier].present? || params[:activity].present?
      base_query = base_query.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?

      @free_count = base_query.free_tier.count
      @premium_count = base_query.premium_tier.count
      @pro_count = base_query.pro_tier.count
    end

    def show
      @wardrobe_items_count = @user.wardrobe_items.count
      @outfits_count = @user.outfits.count
      @suggestions_count = @user.outfit_suggestions.count
      @suggestions_today = @user.outfit_suggestions.where('created_at >= ?', Date.current.beginning_of_day).count

      # Recent activity timeline
      @recent_activities = []

      # Add recent outfit suggestions
      @user.outfit_suggestions.order(created_at: :desc).limit(5).each do |suggestion|
        @recent_activities << {
          text: "Created AI outfit suggestion",
          time: suggestion.created_at.strftime("%b %d, %Y at %I:%M %p"),
          icon: "✨",
          color: "bg-gradient-to-br from-purple-500 to-pink-500"
        }
      end

      # Add recent wardrobe items
      @user.wardrobe_items.order(created_at: :desc).limit(5).each do |item|
        @recent_activities << {
          text: "Added #{item.category} to wardrobe",
          time: item.created_at.strftime("%b %d, %Y at %I:%M %p"),
          icon: "👕",
          color: "bg-gradient-to-br from-blue-500 to-blue-600"
        }
      end

      # Add recent outfits
      @user.outfits.order(created_at: :desc).limit(5).each do |outfit|
        @recent_activities << {
          text: "Created outfit: #{outfit.name}",
          time: outfit.created_at.strftime("%b %d, %Y at %I:%M %p"),
          icon: "🎨",
          color: "bg-gradient-to-br from-green-500 to-emerald-500"
        }
      end

      # Sort by time and take top 10
      @recent_activities = @recent_activities.sort_by { |a| Time.parse(a[:time]) rescue Time.now }.reverse.first(10)

      # Usage stats
      @remaining_suggestions = @user.remaining_suggestions_today
      @image_searches_remaining = @user.remaining_image_searches_today

      # Subscription info
      @subscription = @user.subscription

      # Chart data for AI suggestions over time (last 30 days)
      @user_suggestions_over_time = (0..29).map do |days_ago|
        date = days_ago.days.ago.to_date
        [date.strftime("%b %d"), @user.outfit_suggestions.where(created_at: date.beginning_of_day..date.end_of_day).count]
      end.reverse.to_h

      # Chart data for wardrobe growth (last 30 days)
      @user_wardrobe_growth = (0..29).map do |days_ago|
        date = days_ago.days.ago.to_date
        [date.strftime("%b %d"), @user.wardrobe_items.where(created_at: date.beginning_of_day..date.end_of_day).count]
      end.reverse.to_h
    end

    def update_tier
      new_tier = params[:tier]

      unless %w[free premium pro].include?(new_tier)
        redirect_to admin_user_path(@user), alert: "Invalid tier: #{new_tier}" and return
      end

      if @user.update(subscription_tier: new_tier)
        redirect_to admin_user_path(@user),
                    notice: "User tier updated to #{new_tier.titleize} successfully."
      else
        redirect_to admin_user_path(@user),
                    alert: "Failed to update user tier: #{@user.errors.full_messages.join(', ')}"
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def apply_filters(scope)
      # Filter by subscription tier
      if params[:tier].present? && params[:tier] != "all"
        case params[:tier]
        when "free"
          scope = scope.free_tier
        when "premium"
          scope = scope.premium_tier
        when "pro"
          scope = scope.pro_tier
        when "paying"
          scope = scope.paying_customers
        end
      end

      # Filter by signup date range
      if params[:from_date].present?
        scope = scope.where("users.created_at >= ?", params[:from_date])
      end

      if params[:to_date].present?
        scope = scope.where("users.created_at <= ?", params[:to_date].to_date.end_of_day)
      end

      # Filter by activity level
      if params[:activity].present?
        case params[:activity]
        when "active"
          scope = scope.active_last_30_days
        when "inactive"
          scope = scope.where("updated_at < ?", 30.days.ago)
        end
      end

      scope
    end
  end
end
