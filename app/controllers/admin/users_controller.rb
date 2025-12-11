module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [:show, :update_tier]

    def index
      @users = User.includes(:user_profile, :subscription)
                   .order(created_at: :desc)

      # Apply filters
      @users = apply_filters(@users)

      # Search by email
      if params[:search].present?
        @users = @users.where("email ILIKE ?", "%#{params[:search]}%")
      end

      # Pagination
      @users = @users.page(params[:page]).per(50)

      # Stats for the filtered set
      @total_count = @users.total_count
      @paying_count = @users.where(subscription_tier: ["premium", "pro"]).count
    end

    def show
      @wardrobe_items_count = @user.wardrobe_items.count
      @outfits_count = @user.outfits.count
      @suggestions_count = @user.outfit_suggestions.count
      @suggestions_today = @user.outfit_suggestions.today.count

      # Recent activity
      @recent_suggestions = @user.outfit_suggestions.recent.limit(5)
      @recent_outfits = @user.outfits.order(created_at: :desc).limit(5)

      # Usage stats
      @remaining_suggestions = @user.remaining_suggestions_today
      @image_searches_remaining = @user.remaining_image_searches_today

      # Subscription info
      @subscription = @user.subscription
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
