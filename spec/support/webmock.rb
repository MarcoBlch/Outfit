require 'webmock/rspec'

RSpec.configure do |config|
  # Allow real HTTP connections in system tests
  config.before(:each, type: :system) do
    WebMock.allow_net_connect!
  end

  config.after(:each, type: :system) do
    WebMock.disable_net_connect!
  end

  # Block all external HTTP requests in other test types
  WebMock.disable_net_connect!(
    allow_localhost: true,
    allow: [
      'chromedriver.storage.googleapis.com', # For Selenium
      'googlechromelabs.github.io', # For Selenium
      'edgedl.me.gvt1.com' # For Chrome driver
    ]
  )
end
