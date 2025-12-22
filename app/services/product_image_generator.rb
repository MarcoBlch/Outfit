# frozen_string_literal: true

require 'httparty'

class ProductImageGenerator
  class GenerationError < StandardError; end

  REPLICATE_API_URL = "https://api.replicate.com/v1/predictions"
  # Using Stable Diffusion XL (SDXL) model for high-quality product images
  SDXL_MODEL_VERSION = "stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b"

  PROMPT_TEMPLATE = "Professional product photography of %{gender_prefix}%{category} in %{color_preference}, %{style_notes}, clean white background, studio lighting, commercial quality, high resolution, 4k"

  def initialize(product_recommendation)
    @recommendation = product_recommendation
    @api_token = ENV['REPLICATE_API_TOKEN']
    @user = @recommendation.outfit_suggestion.user
  end

  def generate_image
    validate_api_token!

    # Build the prompt from recommendation details
    prompt = build_prompt

    Rails.logger.info("=== ProductImageGenerator: Starting generation for ProductRecommendation ##{@recommendation.id} ===")
    Rails.logger.info("Category: #{@recommendation.category}")
    Rails.logger.info("Color: #{@recommendation.color_preference}")
    Rails.logger.info("Prompt: #{prompt}")

    # Call Replicate API to generate image
    image_url = call_replicate_api(prompt)

    if image_url
      Rails.logger.info("=== Successfully generated image for ProductRecommendation ##{@recommendation.id}: #{image_url} ===")
      image_url
    else
      error_msg = "Image generation returned nil for ProductRecommendation ##{@recommendation.id}"
      Rails.logger.error("=== #{error_msg} ===")
      raise GenerationError, error_msg
    end
  rescue GenerationError => e
    Rails.logger.error("=== ProductImageGenerator failed for ##{@recommendation.id}: #{e.message} ===")
    # Re-raise to trigger retry mechanism in job
    raise
  rescue StandardError => e
    Rails.logger.error("=== Unexpected error in ProductImageGenerator for ##{@recommendation.id}: #{e.class.name} - #{e.message} ===")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    # Wrap in GenerationError to trigger retry
    raise GenerationError, "Unexpected error: #{e.message}"
  end

  private

  def validate_api_token!
    if @api_token.blank?
      raise GenerationError, "REPLICATE_API_TOKEN not configured"
    end
  end

  def build_prompt
    gender_prefix = determine_gender_prefix

    format(
      PROMPT_TEMPLATE,
      gender_prefix: gender_prefix,
      category: @recommendation.category.presence || "clothing item",
      color_preference: @recommendation.color_preference.presence || "neutral colors",
      style_notes: @recommendation.style_notes.presence || "modern style"
    )
  end

  def determine_gender_prefix
    presentation = @user.user_profile&.presentation_style&.downcase

    case presentation
    when 'masculine'
      "men's "
    when 'feminine'
      "women's "
    when 'androgynous', 'non_binary'
      "unisex "
    else
      "" # neutral, no gender prefix
    end
  end

  def call_replicate_api(prompt)
    # Create prediction request
    response = HTTParty.post(
      REPLICATE_API_URL,
      headers: {
        "Authorization" => "Token #{@api_token}",
        "Content-Type" => "application/json"
      },
      body: {
        version: SDXL_MODEL_VERSION,
        input: {
          prompt: prompt,
          negative_prompt: "blurry, low quality, distorted, watermark, text, logo,人物, person, human, model",
          num_outputs: 1,
          width: 1024,
          height: 1024,
          num_inference_steps: 30,
          guidance_scale: 7.5
        }
      }.to_json,
      timeout: 300 # 5 minutes for image generation
    )

    unless response.success?
      error_message = if response.parsed_response.is_a?(Hash)
                        response.parsed_response["detail"] || response.body
                      else
                        response.body
                      end
      Rails.logger.error("Replicate API Error: #{response.code} - #{error_message}")
      raise GenerationError, "Replicate API failed: #{error_message}"
    end

    prediction_data = response.parsed_response
    prediction_id = prediction_data["id"]

    unless prediction_id
      raise GenerationError, "No prediction ID returned from Replicate API"
    end

    # Poll for completion
    image_url = poll_for_completion(prediction_id)

    image_url
  rescue HTTParty::Error, Net::OpenTimeout => e
    Rails.logger.error("Network error calling Replicate API: #{e.message}")
    raise GenerationError, "Network error: #{e.message}"
  end

  def poll_for_completion(prediction_id)
    max_attempts = 60 # 5 minutes maximum (5 second intervals)
    attempt = 0

    Rails.logger.info("Starting to poll for prediction #{prediction_id}")

    loop do
      attempt += 1

      if attempt > max_attempts
        error_msg = "Image generation timed out after #{max_attempts * 5} seconds"
        Rails.logger.error("Prediction #{prediction_id}: #{error_msg}")
        raise GenerationError, error_msg
      end

      # Get prediction status
      response = HTTParty.get(
        "#{REPLICATE_API_URL}/#{prediction_id}",
        headers: {
          "Authorization" => "Token #{@api_token}",
          "Content-Type" => "application/json"
        },
        timeout: 30
      )

      unless response.success?
        error_msg = "Failed to check prediction status: #{response.code} - #{response.body[0..200]}"
        Rails.logger.error("Prediction #{prediction_id}: #{error_msg}")
        raise GenerationError, error_msg
      end

      prediction = response.parsed_response
      status = prediction["status"]

      Rails.logger.info("Prediction #{prediction_id} status: #{status} (attempt #{attempt}/#{max_attempts})")

      case status
      when "succeeded"
        # Extract image URL from output
        output = prediction["output"]
        image_url = output.is_a?(Array) ? output.first : output

        unless image_url
          Rails.logger.error("Prediction #{prediction_id}: No image URL in output. Full response: #{prediction.inspect[0..500]}")
          raise GenerationError, "No image URL in successful prediction output"
        end

        Rails.logger.info("Prediction #{prediction_id} succeeded with URL: #{image_url}")
        return image_url
      when "failed", "canceled"
        error_message = prediction["error"] || "Unknown error"
        logs = prediction["logs"] || "No logs available"
        Rails.logger.error("Prediction #{prediction_id} #{status}")
        Rails.logger.error("Error: #{error_message}")
        Rails.logger.error("Logs: #{logs[0..1000]}")
        raise GenerationError, "Image generation #{status}: #{error_message}"
      when "starting", "processing"
        # Continue polling
        sleep 5
      else
        Rails.logger.warn("Prediction #{prediction_id}: Unknown status '#{status}' - continuing to poll")
        sleep 5
      end
    end
  rescue HTTParty::Error, Net::OpenTimeout => e
    Rails.logger.error("Network error polling Replicate API for prediction #{prediction_id}: #{e.message}")
    raise GenerationError, "Network error while polling: #{e.message}"
  end
end
