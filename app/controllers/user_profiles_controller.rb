class UserProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user_profile, only: [:edit, :update]

  def new
    @user_profile = current_user.user_profile || current_user.build_user_profile
  end

  def create
    @user_profile = current_user.build_user_profile(user_profile_params)

    if @user_profile.save
      respond_to do |format|
        format.html do
          redirect_to root_path, notice: "Profile created successfully! You'll now get better outfit recommendations."
        end
        format.turbo_stream do
          # Build style summary for the completion modal
          summary_items = [
            { icon: style_icon(@user_profile.style_preference), label: "Style", value: @user_profile.style_preference&.humanize },
            { icon: "🎨", label: "Colors", value: "#{@user_profile.favorite_colors.count} favorites" },
            { icon: fit_icon(@user_profile.fit_preference), label: "Fit", value: @user_profile.fit_preference&.humanize },
            { icon: goal_icon(@user_profile.primary_goal), label: "Goal", value: @user_profile.primary_goal&.humanize }
          ].compact

          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "user_profiles/quiz_complete_modal",
            locals: {
              message: "Your personalized style profile is ready! Get outfit recommendations tailored to your unique preferences.",
              redirect_path: root_path,
              summary_items: summary_items
            }
          )
        end
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "profile-form",
            partial: "user_profiles/form",
            locals: { user_profile: @user_profile }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    # Edit view
  end

  def update
    if @user_profile.update(user_profile_params)
      respond_to do |format|
        format.html do
          redirect_to root_path, notice: "Profile updated successfully!"
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "shared/modal_success",
            locals: {
              title: "Profile Updated!",
              message: "Your preferences have been saved.",
              redirect_path: root_path
            }
          )
        end
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "profile-form",
            partial: "user_profiles/form",
            locals: { user_profile: @user_profile }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_user_profile
    @user_profile = current_user.user_profile || current_user.build_user_profile
  end

  def style_icon(style)
    icons = {
      'casual' => '👕',
      'business_casual' => '👔',
      'formal' => '🎩',
      'streetwear' => '👟',
      'minimalist' => '⚪',
      'bohemian' => '🌸',
      'eclectic' => '🎨'
    }
    icons[style] || '👕'
  end

  def fit_icon(fit)
    icons = {
      'relaxed' => '🛋️',
      'regular' => '👕',
      'fitted' => '📏',
      'tailored' => '✂️'
    }
    icons[fit] || '👕'
  end

  def goal_icon(goal)
    icons = {
      'organize_existing' => '📋',
      'get_outfit_ideas' => '💡',
      'reduce_wardrobe' => '♻️',
      'build_capsule' => '🎯',
      'track_value' => '💰',
      'shop_smarter' => '🛒'
    }
    icons[goal] || '🎯'
  end

  def user_profile_params
    # Handle array parameters and metadata
    params.require(:user_profile).permit(
      :style_preference,
      :body_type,
      :presentation_style,
      :age_range,
      :location,
      :fit_preference,
      :wardrobe_size,
      :shopping_frequency,
      :primary_goal,
      :budget_range,
      favorite_colors: [],
      occasion_focus: []
    ).tap do |whitelisted|
      # Initialize metadata hash
      metadata = {}

      # Convert favorite_colors to metadata format
      if params[:user_profile][:favorite_colors].present?
        colors = params[:user_profile][:favorite_colors].reject(&:blank?)
        metadata[:favorite_colors] = colors
        whitelisted.delete(:favorite_colors)
      end

      # Convert occasion_focus to metadata format
      if params[:user_profile][:occasion_focus].present?
        occasions = params[:user_profile][:occasion_focus].reject(&:blank?)
        metadata[:occasion_focus] = occasions
        whitelisted.delete(:occasion_focus)
      end

      # Convert budget_range to metadata format (optional field)
      if params[:user_profile][:budget_range].present?
        metadata[:budget_range] = params[:user_profile][:budget_range]
        whitelisted.delete(:budget_range)
      end

      # Set metadata if we have any
      whitelisted[:metadata] = metadata if metadata.any?
    end
  end
end
