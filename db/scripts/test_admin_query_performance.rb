#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Admin Dashboard query performance
# Usage: rails runner db/scripts/test_admin_query_performance.rb

require 'benchmark'

class AdminQueryPerformanceTest
  PERFORMANCE_THRESHOLD_MS = 100 # All queries should complete in < 100ms

  def initialize
    @results = []
    @failures = []
  end

  def run_all_tests
    puts "=" * 80
    puts "Admin Dashboard Query Performance Tests"
    puts "=" * 80
    puts "Performance threshold: #{PERFORMANCE_THRESHOLD_MS}ms"
    puts "Current data: #{User.count} users, #{OutfitSuggestion.count} suggestions, #{AdImpression.count} ad impressions"
    puts "=" * 80
    puts

    # User queries
    test_query("User count by subscription tier") do
      User.group(:subscription_tier).count
    end

    test_query("Recent signups (last 30 days)") do
      User.recent_signups(30).count
    end

    test_query("Active users (last 7 days)") do
      User.active.count
    end

    test_query("Paying users") do
      User.paying.count
    end

    test_query("Premium tier users") do
      User.premium_tier.count
    end

    test_query("Pro tier users") do
      User.pro_tier.count
    end

    # MRR calculation
    test_query("MRR calculation") do
      tier_counts = User.group(:subscription_tier).count
      {
        total: (tier_counts['premium'].to_i * 7.99) + (tier_counts['pro'].to_i * 14.99),
        premium: tier_counts['premium'].to_i * 7.99,
        pro: tier_counts['pro'].to_i * 14.99
      }
    end

    # Outfit suggestion queries
    test_query("Suggestions today") do
      OutfitSuggestion.where('created_at >= ?', Time.current.beginning_of_day).count
    end

    test_query("Suggestions this week") do
      OutfitSuggestion.where('created_at >= ?', 1.week.ago).count
    end

    test_query("Suggestions this month") do
      OutfitSuggestion.where('created_at >= ?', 1.month.ago).count
    end

    test_query("Top 10 contexts") do
      OutfitSuggestion.where('created_at >= ?', 30.days.ago)
                      .group(:context)
                      .count
                      .sort_by { |_, count| -count }
                      .first(10)
    end

    test_query("AI cost this month") do
      OutfitSuggestion.where('created_at >= ?', 1.month.ago).sum(:api_cost)
    end

    test_query("AI cost per tier this month") do
      OutfitSuggestion.joins(:user)
                      .where('outfit_suggestions.created_at >= ?', 1.month.ago)
                      .group('users.subscription_tier')
                      .sum('outfit_suggestions.api_cost')
    end

    # Ad impression queries
    if AdImpression.any?
      test_query("Ad impressions today") do
        AdImpression.today.count
      end

      test_query("Ad revenue this month") do
        AdImpression.this_month.total_revenue
      end

      test_query("Ad CTR by placement") do
        AdImpression.this_month.ctr_by_placement
      end

      test_query("Daily ad revenue (30 days)") do
        AdImpression.daily_revenue(days: 30)
      end
    end

    # Complex user stats query (simulates user list page)
    test_query("User list with stats (50 users)") do
      User.select('users.*,
                   COUNT(DISTINCT wardrobe_items.id) AS wardrobe_items_count,
                   COUNT(DISTINCT outfits.id) AS outfits_count,
                   COUNT(DISTINCT outfit_suggestions.id) AS outfit_suggestions_count')
          .left_joins(:wardrobe_items, :outfits, :outfit_suggestions)
          .group('users.id')
          .limit(50)
          .to_a
    end

    # Cohort analysis
    test_query("Signups by month (last 6 months)") do
      User.where('created_at >= ?', 6.months.ago)
          .group("DATE_TRUNC('month', created_at)")
          .count
    end

    # Print results
    print_results
  end

  private

  def test_query(description, &block)
    print "Testing: #{description}... "

    # Warm up the query cache
    block.call

    # Clear query cache for accurate measurement
    ActiveRecord::Base.connection.query_cache.clear

    # Measure query time
    time = Benchmark.realtime { block.call }
    time_ms = (time * 1000).round(2)

    # Check if within threshold
    passed = time_ms < PERFORMANCE_THRESHOLD_MS

    @results << {
      description: description,
      time_ms: time_ms,
      passed: passed
    }

    @failures << description unless passed

    puts passed ? "✓ #{time_ms}ms" : "✗ #{time_ms}ms (SLOW!)"
  rescue StandardError => e
    puts "✗ ERROR: #{e.message}"
    @failures << description
    @results << {
      description: description,
      time_ms: nil,
      passed: false,
      error: e.message
    }
  end

  def print_results
    puts
    puts "=" * 80
    puts "Results Summary"
    puts "=" * 80

    total_tests = @results.size
    passed_tests = @results.count { |r| r[:passed] }
    failed_tests = total_tests - passed_tests

    puts "Total tests: #{total_tests}"
    puts "Passed: #{passed_tests} (#{(passed_tests.to_f / total_tests * 100).round(1)}%)"
    puts "Failed: #{failed_tests}"
    puts

    if @failures.any?
      puts "Failed queries:"
      @failures.each { |desc| puts "  - #{desc}" }
      puts
    end

    # Calculate stats
    times = @results.map { |r| r[:time_ms] }.compact
    if times.any?
      avg_time = (times.sum / times.size).round(2)
      max_time = times.max.round(2)
      min_time = times.min.round(2)

      puts "Performance stats:"
      puts "  Average: #{avg_time}ms"
      puts "  Min: #{min_time}ms"
      puts "  Max: #{max_time}ms"
      puts
    end

    if @failures.empty?
      puts "✓ All queries passed!"
    else
      puts "✗ Some queries need optimization"
    end

    puts "=" * 80
  end
end

# Run tests
tester = AdminQueryPerformanceTest.new
tester.run_all_tests
