#!/usr/bin/env ruby
# frozen_string_literal: true

# Seed script for Admin Dashboard testing
# Usage: rails runner db/scripts/seed_admin_test_data.rb

puts "=" * 80
puts "Seeding Admin Dashboard Test Data"
puts "=" * 80

# Configuration
USERS_TO_CREATE = 100
SUGGESTIONS_PER_USER = 5
AD_IMPRESSIONS_PER_USER = 10

# Start transaction for rollback capability
ActiveRecord::Base.transaction do
  puts "\nCreating users..."
  users_created = 0

  USERS_TO_CREATE.times do |i|
    # Random subscription tier (70% free, 20% premium, 10% pro)
    tier = case rand(1..10)
           when 1..7 then 'free'
           when 8..9 then 'premium'
           else 'pro'
           end

    # Random signup date (last 6 months)
    signup_date = rand(180).days.ago

    user = User.create!(
      email: "test_user_#{i}@example.com",
      password: 'password123',
      password_confirmation: 'password123',
      subscription_tier: tier,
      admin: false,
      created_at: signup_date,
      updated_at: signup_date
    )

    users_created += 1
    print "\rCreated #{users_created}/#{USERS_TO_CREATE} users..."
  end

  puts "\n✓ Created #{users_created} users"

  # Create one admin user
  admin = User.create!(
    email: 'admin@outfit.com',
    password: 'admin123',
    password_confirmation: 'admin123',
    subscription_tier: 'pro',
    admin: true
  )
  puts "✓ Created admin user: #{admin.email}"

  # Create outfit suggestions
  puts "\nCreating outfit suggestions..."
  contexts = [
    'casual day out',
    'business meeting',
    'date night',
    'job interview',
    'party',
    'workout',
    'beach day',
    'formal event',
    'brunch',
    'travel'
  ]

  suggestions_created = 0
  User.where(admin: false).find_each do |user|
    # Create random number of suggestions (0-SUGGESTIONS_PER_USER)
    num_suggestions = rand(0..SUGGESTIONS_PER_USER)

    num_suggestions.times do
      suggestion_date = rand((user.created_at.to_date..Date.current).to_a)

      OutfitSuggestion.create!(
        user: user,
        context: contexts.sample,
        status: 'completed',
        api_cost: rand(0.005..0.02).round(4),
        suggestions_count: rand(1..3),
        response_time_ms: rand(500..2000),
        created_at: suggestion_date,
        updated_at: suggestion_date
      )

      suggestions_created += 1
    end

    print "\rCreated #{suggestions_created} outfit suggestions..."
  end

  puts "\n✓ Created #{suggestions_created} outfit suggestions"

  # Create ad impressions (only for free tier users)
  puts "\nCreating ad impressions..."
  placements = %w[dashboard_banner wardrobe_grid outfit_modal]
  impressions_created = 0

  User.free_tier.where(admin: false).find_each do |user|
    # Create random number of ad impressions
    num_impressions = rand(0..AD_IMPRESSIONS_PER_USER)

    num_impressions.times do
      impression_date = rand((user.created_at.to_date..Date.current).to_a)
      placement = placements.sample

      # 2-5% CTR
      clicked = rand(1..100) <= 3

      AdImpression.create!(
        user: user,
        placement: placement,
        clicked: clicked,
        revenue: AdImpression.calculate_revenue_from_cpm(rand(1.5..3.0)),
        ad_network: 'google_adsense',
        created_at: impression_date,
        updated_at: impression_date
      )

      impressions_created += 1
    end

    print "\rCreated #{impressions_created} ad impressions..."
  end

  puts "\n✓ Created #{impressions_created} ad impressions"

  # Print summary
  puts "\n" + "=" * 80
  puts "Summary"
  puts "=" * 80
  puts "Users: #{User.count}"
  puts "  - Free: #{User.free_tier.count}"
  puts "  - Premium: #{User.premium_tier.count}"
  puts "  - Pro: #{User.pro_tier.count}"
  puts "  - Admins: #{User.admins.count}"
  puts
  puts "Outfit Suggestions: #{OutfitSuggestion.count}"
  puts "  - Total cost: $#{OutfitSuggestion.sum(:api_cost).round(2)}"
  puts
  puts "Ad Impressions: #{AdImpression.count}"
  puts "  - Total revenue: $#{AdImpression.total_revenue.to_f.round(2)}"
  puts "  - CTR: #{AdImpression.click_through_rate}%"
  puts "=" * 80

  # Ask for confirmation to commit
  puts "\nType 'yes' to commit this data, or press Enter to rollback:"
  response = STDIN.gets.chomp

  if response.downcase == 'yes'
    puts "✓ Committing data..."
  else
    puts "✗ Rolling back..."
    raise ActiveRecord::Rollback
  end
end

puts "\nDone!"
