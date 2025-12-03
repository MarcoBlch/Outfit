require "httparty"
require "googleauth"

class EmbeddingService
  class EmbeddingError < StandardError; end

  def initialize
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @location = ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1"
    # text-embedding-004 is a stable, high-performance model
    @api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/text-embedding-004:predict"
  end

  def embed(text)
    return [] if text.blank?

    # Get Access Token
    authorizer = Google::Auth.get_application_default
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
      @api_endpoint,
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
end
