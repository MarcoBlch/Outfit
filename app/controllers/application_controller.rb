class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # TEMPORARY: Override current_user for AI navigation testing
  # This provides a demo user when no one is logged in
  def current_user
    super || demo_user
  end

  private

  def demo_user
    @demo_user ||= User.first # Uses the first user in the database as a demo
  end
end
