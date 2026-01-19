class LandingController < ApplicationController
  def index
    # TEMPORARY: Allow AI navigation without login
    # Redirect to dashboard if already logged in
    # if user_signed_in?
    #   redirect_to authenticated_root_path
    # end
  end
end
