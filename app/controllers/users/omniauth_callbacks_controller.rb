# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_omniauth("Google")
  end

  def facebook
    handle_omniauth("Facebook")
  end

  def apple
    handle_omniauth("Apple")
  end

  def failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end

  private

  def handle_omniauth(provider)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = "Signed in with #{provider} successfully."
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.omniauth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: "Could not create account. Please try registering with email."
    end
  end
end
