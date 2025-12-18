# frozen_string_literal: true

class GenerateProductImageJob < ApplicationJob
  queue_as :default

  # Retry up to 2 times with polynomial backoff (3 minutes, 9 minutes)
  retry_on ProductImageGenerator::GenerationError, wait: :polynomially_longer, attempts: 2

  def perform(product_recommendation_id)
    recommendation = ProductRecommendation.find_by(id: product_recommendation_id)

    unless recommendation
      Rails.logger.warn("GenerateProductImageJob: ProductRecommendation ##{product_recommendation_id} not found")
      return
    end

    Rails.logger.info("Starting image generation for ProductRecommendation ##{recommendation.id}")

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

      Rails.logger.info("Successfully completed image generation for ProductRecommendation ##{recommendation.id}")
    else
      # Mark as failed if no URL returned
      recommendation.mark_image_failed!("Image generation returned no URL")
      Rails.logger.error("Image generation failed for ProductRecommendation ##{recommendation.id}: No URL returned")
    end
  rescue StandardError => e
    # Mark as failed on any unexpected error
    if recommendation
      recommendation.mark_image_failed!(e.message)
    end

    Rails.logger.error("GenerateProductImageJob failed for ProductRecommendation ##{product_recommendation_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))

    # Re-raise to trigger retry mechanism
    raise
  end
end
