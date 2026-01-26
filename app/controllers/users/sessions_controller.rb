class Users::SessionsController < Devise::SessionsController
  respond_to :html, :json

  private

  def respond_with(resource, _opts = {})
    respond_to do |format|
      format.html { super }
      format.json do
        render json: {
          message: 'Logged in successfully.',
          user: resource,
        }, status: :ok
      end
    end
  end

  def respond_to_on_destroy
    respond_to do |format|
      format.html do
        # Standard Devise behavior - redirect after logout
        redirect_to after_sign_out_path_for(resource_name), status: :see_other
      end
      format.json do
        if request.headers['Authorization'].present?
          render json: { message: "Logged out successfully" }, status: :ok
        else
          render json: { message: "Couldn't find an active session." }, status: :unauthorized
        end
      end
    end
  end
end
