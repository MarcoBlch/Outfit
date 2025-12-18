# frozen_string_literal: true

class FetchAffiliateProductsJob < ApplicationJob
  queue_as :default

  # Retry up to 2 times with polynomial backoff (3 minutes, 9 minutes)
  retry_on AmazonProductMatcher::MatchingError, wait: :polynomially_longer, attempts: 2

  def perform(product_recommendation_id)
    recommendation = ProductRecommendation.find_by(id: product_recommendation_id)

    unless recommendation
      Rails.logger.warn("FetchAffiliateProductsJob: ProductRecommendation ##{product_recommendation_id} not found")
      return
    end

    Rails.logger.info("Starting affiliate product fetch for ProductRecommendation ##{recommendation.id}")

    # Call Amazon Product Matcher service
    matcher = AmazonProductMatcher.new(recommendation)
    products = matcher.find_matching_products(limit: 5)

    if products.any?
      Rails.logger.info("Successfully fetched #{products.size} affiliate products for ProductRecommendation ##{recommendation.id}")
    else
      Rails.logger.warn("No affiliate products found for ProductRecommendation ##{recommendation.id}")
    end
  rescue StandardError => e
    Rails.logger.error("FetchAffiliateProductsJob failed for ProductRecommendation ##{product_recommendation_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    # Re-raise to trigger retry mechanism
    raise
  end
end
