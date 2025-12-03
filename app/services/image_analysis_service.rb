require "google/cloud/ai_platform/v1"
require "httparty"
require "googleauth"

class ImageAnalysisService
  class AnalysisError < StandardError; end

  def initialize
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @location = ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1"
    # Updated to use current Gemini 2.5 model (gemini-1.5 was retired in September 2025)
    @api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/gemini-2.5-flash:generateContent"
  end

  def analyze(image_path)
    # Read image file and encode to Base64
    image_content = File.binread(image_path)
    encoded_image = Base64.strict_encode64(image_content)

    # Get Access Token
    authorizer = Google::Auth.get_application_default
    token = authorizer.fetch_access_token!["access_token"]

    # Construct the prompt for Gemini
    prompt_text = <<~PROMPT
      Analyze this clothing item. Return a JSON object with the following keys:
      - category: The specific category of the item (e.g., "t-shirt", "jeans", "dress", "sneakers").
      - color: The primary color of the item.
      - description: A detailed visual description of the item, including pattern, texture, and style details.
      - tags: A list of 3-5 keywords describing the style or occasion (e.g., "casual", "summer", "formal").
      
      Ensure the output is valid JSON. Do not include markdown formatting like ```json.
    PROMPT

    # Construct Request Body
    body = {
      contents: [
        {
          role: "user",
          parts: [
            { text: prompt_text },
            { 
              inline_data: {
                mime_type: "image/jpeg", 
                data: encoded_image
              }
            }
          ]
        }
      ],
      generationConfig: {
        temperature: 0.4,
        topP: 1.0,
        topK: 32,
        maxOutputTokens: 2048,
        responseMimeType: "application/json"
      }
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
      Rails.logger.error("Vertex AI Error: #{response.body}")
      raise AnalysisError, "Vertex AI API failed: #{response.body}"
    end
  rescue => e
    Rails.logger.error("Image Analysis Failed: #{e.message}")
    raise AnalysisError, "Image Analysis Failed: #{e.message}"
  end

  private

  def parse_response(response_body)
    candidates = response_body["candidates"]
    if candidates.nil? || candidates.empty?
      raise AnalysisError, "No candidates returned from Vertex AI"
    end

    # Extract text
    candidate = candidates.first
    raw_text = candidate.dig("content", "parts", 0, "text")
    
    if raw_text.nil?
      Rails.logger.error("Unexpected Gemini response structure: #{response_body}")
      raise AnalysisError, "Could not extract text from Gemini response"
    end

    parse_json_response(raw_text)
  end

  def parse_json_response(text)
    # Clean up markdown if present (e.g. ```json ... ```)
    cleaned_text = text.gsub(/```json\n?/, "").gsub(/```/, "").strip
    JSON.parse(cleaned_text)
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse JSON from Gemini: #{text}")
    raise AnalysisError, "Invalid JSON response from AI model"
  end
end
