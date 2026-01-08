class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  private

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def respond_with(resource, _opts = {})
    respond_to do |format|
      format.html { super }
      format.json do
        if resource.persisted?
          render json: {
            message: 'Signed up successfully.',
            user: resource,
          }, status: :ok
        else
          render json: {
            message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
