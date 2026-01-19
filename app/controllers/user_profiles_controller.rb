class UserProfilesController < ApplicationController
  # TEMPORARY: Authentication disabled for AI navigation testing
  # before_action :authenticate_user!
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
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "shared/modal_success",
            locals: {
              title: "Profile Complete!",
              message: "You'll now get better outfit recommendations based on your preferences.",
              redirect_path: root_path
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

  def user_profile_params
    # Handle favorite_colors array parameter
    params.require(:user_profile).permit(
      :style_preference,
      :body_type,
      :presentation_style,
      :age_range,
      :location,
      favorite_colors: []
    ).tap do |whitelisted|
      # Convert favorite_colors to metadata format
      if params[:user_profile][:favorite_colors].present?
        colors = params[:user_profile][:favorite_colors].reject(&:blank?)
        whitelisted[:metadata] = { favorite_colors: colors }
        whitelisted.delete(:favorite_colors)
      end
    end
  end
end
