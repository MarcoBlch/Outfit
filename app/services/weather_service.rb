require "httparty"

class WeatherService
  class WeatherError < StandardError; end

  API_BASE_URL = "https://api.openweathermap.org/data/2.5/weather"
  CACHE_DURATION = 30.minutes

  def initialize(location)
    @location = location
    @api_key = ENV["OPENWEATHER_API_KEY"]
  end

  # Returns current weather conditions
  # Returns nil if API key is missing or API call fails
  def current_conditions
    return nil if @location.blank?
    return nil if @api_key.blank?

    # Check cache first
    cache_key = "weather:#{normalized_location}"
    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data.present?

    # Fetch from API
    weather_data = fetch_weather_data
    return nil if weather_data.nil?

    # Parse and cache
    conditions = parse_weather_response(weather_data)
    Rails.cache.write(cache_key, conditions, expires_in: CACHE_DURATION)

    conditions
  rescue WeatherError => e
    Rails.logger.warn("Weather API error: #{e.message}")
    nil
  rescue StandardError => e
    Rails.logger.error("Unexpected weather service error: #{e.message}")
    nil
  end

  private

  def fetch_weather_data
    response = HTTParty.get(
      API_BASE_URL,
      query: {
        q: @location,
        appid: @api_key,
        units: "imperial" # Fahrenheit
      },
      timeout: 10
    )

    unless response.success?
      error_message = response.parsed_response&.dig("message") || "Unknown error"
      raise WeatherError, "API returned #{response.code}: #{error_message}"
    end

    response.parsed_response
  rescue HTTParty::Error, Net::OpenTimeout => e
    raise WeatherError, "Network error: #{e.message}"
  end

  def parse_weather_response(data)
    {
      temp: data.dig("main", "temp")&.round || 0,
      feels_like: data.dig("main", "feels_like")&.round || 0,
      condition: data.dig("weather", 0, "description") || "unknown",
      humidity: data.dig("main", "humidity") || 0,
      wind_speed: data.dig("wind", "speed")&.round(1) || 0.0
    }
  end

  def normalized_location
    @location.to_s.downcase.strip
  end
end
