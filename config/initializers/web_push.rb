# frozen_string_literal: true

# Web Push configuration for push notifications
#
# To generate VAPID keys, run in Rails console:
#   vapid_key = WebPush.generate_key
#   puts "Public Key: #{vapid_key.public_key}"
#   puts "Private Key: #{vapid_key.private_key}"
#
# Then add to config/credentials.yml.enc:
#   EDITOR="nano" rails credentials:edit
#
# Add:
#   web_push:
#     public_key: your_public_key_here
#     private_key: your_private_key_here
#
# Or use environment variables (for development):
#   VAPID_PUBLIC_KEY=your_public_key_here
#   VAPID_PRIVATE_KEY=your_private_key_here

if Rails.env.production?
  # In production, use Rails credentials
  VAPID_PUBLIC_KEY = Rails.application.credentials.dig(:web_push, :public_key)
  VAPID_PRIVATE_KEY = Rails.application.credentials.dig(:web_push, :private_key)

  if VAPID_PUBLIC_KEY.blank? || VAPID_PRIVATE_KEY.blank?
    Rails.logger.warn("VAPID keys not configured in credentials. Push notifications will not work.")
  end
else
  # In development/test, use environment variables or generate temporary keys
  VAPID_PUBLIC_KEY = ENV["VAPID_PUBLIC_KEY"]
  VAPID_PRIVATE_KEY = ENV["VAPID_PRIVATE_KEY"]

  if VAPID_PUBLIC_KEY.blank? || VAPID_PRIVATE_KEY.blank?
    Rails.logger.info("VAPID keys not configured. Generating temporary keys for development.")
    Rails.logger.info("Run in console to generate persistent keys:")
    Rails.logger.info("  vapid_key = WebPush.generate_key")
    Rails.logger.info("  puts \"VAPID_PUBLIC_KEY=#{vapid_key.public_key}\"")
    Rails.logger.info("  puts \"VAPID_PRIVATE_KEY=#{vapid_key.private_key}\"")
  end
end

# Subject for VAPID (required, typically your email or website)
VAPID_SUBJECT = ENV.fetch("VAPID_SUBJECT", "mailto:support@outfitmaker.com")
