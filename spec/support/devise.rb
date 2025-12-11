RSpec.configure do |config|
  # Include Devise test helpers for controller and request specs
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
end
