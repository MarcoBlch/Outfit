module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    layout "admin"

    private

    def require_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Access denied. Admin privileges required."
      end
    end

    # Helper method for breadcrumbs
    helper_method :admin_breadcrumbs

    def admin_breadcrumbs
      @admin_breadcrumbs ||= [{ name: "Admin Dashboard", path: admin_root_path }]
    end
  end
end
