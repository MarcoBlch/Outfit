namespace :vapid do
  desc "Generate VAPID keys for web push notifications"
  task generate: :environment do
    require 'web-push'

    vapid_key = WebPush.generate_key

    puts "\n" + "="*60
    puts "VAPID Keys Generated Successfully!"
    puts "="*60
    puts "\nCopy these values to your Railway environment variables:\n\n"
    puts "VAPID_PUBLIC_KEY=#{vapid_key.public_key}"
    puts "VAPID_PRIVATE_KEY=#{vapid_key.private_key}"
    puts "VAPID_SUBJECT=mailto:support@outfitmaker.com"
    puts "\n" + "="*60
    puts "\nTo set these in Railway, run:"
    puts "railway variables --set \"VAPID_PUBLIC_KEY=#{vapid_key.public_key}\""
    puts "railway variables --set \"VAPID_PRIVATE_KEY=#{vapid_key.private_key}\""
    puts "railway variables --set \"VAPID_SUBJECT=mailto:support@outfitmaker.com\""
    puts "="*60 + "\n"
  end
end
