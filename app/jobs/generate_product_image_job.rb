# frozen_string_literal: true

class GenerateProductImageJob < ApplicationJob
  queue_as :default

  # Retry up to 3 times with polynomial backoff (3 minutes, 9 minutes, 27 minutes)
  # This allows for temporary API issues or rate limits
  retry_on ProductImageGenerator::GenerationError, wait: :polynomially_longer, attempts: 3

  def perform(product_recommendation_id)
    recommendation = ProductRecommendation.find_by(id: product_recommendation_id)

    unless recommendation
      Rails.logger.warn("GenerateProductImageJob: ProductRecommendation ##{product_recommendation_id} not found")
      return
    end

    attempt_number = executions
    Rails.logger.info("=== GenerateProductImageJob: Attempt #{attempt_number} for ProductRecommendation ##{recommendation.id} ===")

    # Mark as generating before starting
    recommendation.mark_image_generating!

    # Call the ProductImageGenerator service
    generator = ProductImageGenerator.new(recommendation)
    image_url = generator.generate_image

    if image_url
      # Calculate approximate cost (SDXL typically costs ~$0.0025 per image)
      estimated_cost = 0.0025

      # Mark as completed with the image URL
      recommendation.mark_image_completed!(image_url, estimated_cost)

      Rails.logger.info("=== GenerateProductImageJob: Successfully completed for ProductRecommendation ##{recommendation.id} on attempt #{attempt_number} ===")
    else
      # This shouldn't happen anymore as generator.generate_image raises on nil
      error_msg = "Image generation returned no URL"
      recommendation.mark_image_failed!(error_msg)
      Rails.logger.error("=== GenerateProductImageJob: #{error_msg} for ProductRecommendation ##{recommendation.id} ===")
      raise ProductImageGenerator::GenerationError, error_msg
    end
  rescue ProductImageGenerator::GenerationError => e
    # Mark as failed - will retry automatically
    if recommendation
      recommendation.mark_image_failed!(e.message)
    end

    Rails.logger.error("=== GenerateProductImageJob: Generation error for ProductRecommendation ##{product_recommendation_id} (attempt #{attempt_number}): #{e.message} ===")

    # Re-raise to trigger retry mechanism
    raise
  rescue StandardError => e
    # Mark as failed on any unexpected error
    if recommendation
      recommendation.mark_image_failed!(e.message)
    end

    Rails.logger.error("=== GenerateProductImageJob: Unexpected error for ProductRecommendation ##{product_recommendation_id}: #{e.class.name} - #{e.message} ===")
    Rails.logger.error(e.backtrace.first(10).join("\n"))

    # Wrap in GenerationError to trigger retry mechanism
    raise ProductImageGenerator::GenerationError, "Unexpected error: #{e.message}"
  end
end
