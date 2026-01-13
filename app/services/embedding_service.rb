require "httparty"
require "googleauth"

class EmbeddingService
  class EmbeddingError < StandardError; end

  def initialize
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @location = ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1"
    # text-embedding-004 is a stable, high-performance model for text
    @text_api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/text-embedding-004:predict"
    # multimodalembedding@001 for images and multimodal content
    @multimodal_api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/multimodalembedding@001:predict"
  end

  def embed(text)
    return [] if text.blank?

    # Get Access Token with proper scopes for Vertex AI
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    authorizer = Google::Auth.get_application_default(scopes)
    token = authorizer.fetch_access_token!["access_token"]

    # Construct Request Body
    # Task type: SEMANTIC_SIMILARITY is good for search
    body = {
      instances: [
        {
          content: text,
          task_type: "SEMANTIC_SIMILARITY"
        }
      ]
    }

    # Make Request
    response = HTTParty.post(
      @text_api_endpoint,
      headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    if response.success?
      parse_response(response.parsed_response)
    else
      Rails.logger.error("Embedding Error: #{response.body}")
      raise EmbeddingError, "Vertex AI Embedding failed: #{response.body}"
    end
  rescue => e
    Rails.logger.error("Embedding Failed: #{e.message}")
    raise EmbeddingError, "Embedding Failed: #{e.message}"
  end

  # Embed an image using multimodal embeddings
  # Accepts either a base64 string or a file path/IO object
  def embed_image(image_data, mime_type: "image/jpeg")
    return [] if image_data.blank?

    base64_image = if image_data.is_a?(String) && File.exist?(image_data)
      Base64.strict_encode64(File.read(image_data))
    elsif image_data.respond_to?(:read)
      Base64.strict_encode64(image_data.read)
    else
      # Assume it's already base64 encoded
      image_data
    end

    # Get Access Token with proper scopes for Vertex AI
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    authorizer = Google::Auth.get_application_default(scopes)
    token = authorizer.fetch_access_token!["access_token"]

    # Construct Request Body for multimodal embedding
    body = {
      instances: [
        {
          image: {
            bytesBase64Encoded: base64_image
          }
        }
      ]
    }

    # Make Request to multimodal endpoint
    response = HTTParty.post(
      @multimodal_api_endpoint,
      headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json,
      timeout: 30
    )

    if response.success?
      parse_multimodal_response(response.parsed_response)
    else
      Rails.logger.error("Image Embedding Error: #{response.body}")
      raise EmbeddingError, "Vertex AI Image Embedding failed: #{response.body}"
    end
  rescue => e
    Rails.logger.error("Image Embedding Failed: #{e.message}")
    raise EmbeddingError, "Image Embedding Failed: #{e.message}"
  end

  private

  def parse_response(response_body)
    predictions = response_body["predictions"]
    if predictions.nil? || predictions.empty?
      raise EmbeddingError, "No predictions returned from Vertex AI"
    end

    # Extract embedding vector
    # Structure: predictions[0].embeddings.values
    embedding = predictions.first.dig("embeddings", "values")
    
    if embedding.nil?
      Rails.logger.error("Unexpected Embedding response structure: #{response_body}")
      raise EmbeddingError, "Could not extract embedding from response"
    end

    embedding
  end

  def parse_multimodal_response(response_body)
    predictions = response_body["predictions"]
    if predictions.nil? || predictions.empty?
      raise EmbeddingError, "No predictions returned from Vertex AI Multimodal"
    end

    # Multimodal embeddings return imageEmbedding
    embedding = predictions.first&.dig("imageEmbedding")

    if embedding.nil?
      Rails.logger.error("Unexpected Multimodal Embedding response structure: #{response_body}")
      raise EmbeddingError, "Could not extract image embedding from response"
    end

    embedding
  end
end
