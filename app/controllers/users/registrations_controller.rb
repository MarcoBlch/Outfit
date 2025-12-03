class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

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
