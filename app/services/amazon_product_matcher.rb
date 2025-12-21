# frozen_string_literal: true

require 'net/http'
require 'json'

class AmazonProductMatcher
  class MatchingError < StandardError; end

  # Budget range price mappings (in USD)
  BUDGET_PRICE_RANGES = {
    budget: { min: 0, max: 50 },        # $0-50
    mid_range: { min: 30, max: 150 },   # $30-150
    premium: { min: 100, max: 300 },    # $100-300
    luxury: { min: 250, max: nil }      # $250+
  }.freeze

  # RapidAPI Real-Time Amazon Data endpoint
  RAPIDAPI_BASE_URL = 'https://real-time-amazon-data.p.rapidapi.com'

  def initialize(product_recommendation)
    @recommendation = product_recommendation
    @rapidapi_key = ENV['RAPIDAPI_KEY']
    @rapidapi_host = ENV['RAPIDAPI_HOST'] || 'real-time-amazon-data.p.rapidapi.com'
    @partner_tag = ENV['AMAZON_ASSOCIATE_TAG'] || ENV['AMAZON_PARTNER_TAG']
    @marketplace = ENV['AMAZON_MARKETPLACE'] || 'US'
  end

  def find_matching_products(limit: 5)
    validate_credentials!

    Rails.logger.info("Starting Amazon product search for ProductRecommendation ##{@recommendation.id}")

    # Build search query
    search_query = build_search_query
    Rails.logger.info("Search query: #{search_query}")

    # Search Amazon via RapidAPI
    products = search_amazon_rapidapi(search_query, limit)

    # Store results in recommendation
    if products.any?
      @recommendation.update!(affiliate_products: products)
      Rails.logger.info("Successfully found #{products.size} products for ProductRecommendation ##{@recommendation.id}")
    else
      Rails.logger.warn("No products found for ProductRecommendation ##{@recommendation.id}")
    end

    products
  rescue MatchingError => e
    Rails.logger.error("Amazon Product Matching Failed for ##{@recommendation.id}: #{e.message}")
    []
  rescue StandardError => e
    Rails.logger.error("Unexpected error in AmazonProductMatcher: #{e.message}\n#{e.backtrace.join("\n")}")
    []
  end

  private

  def validate_credentials!
    missing_configs = []
    missing_configs << 'RAPIDAPI_KEY' if @rapidapi_key.blank?
    missing_configs << 'AMAZON_ASSOCIATE_TAG' if @partner_tag.blank?

    if missing_configs.any?
      raise MatchingError, "Missing required configuration: #{missing_configs.join(', ')}"
    end
  end

  def build_search_query
    parts = []

    # Add category
    parts << @recommendation.category if @recommendation.category.present?

    # Add color preference
    parts << @recommendation.color_preference if @recommendation.color_preference.present?

    # Add style keywords from style_notes if available
    if @recommendation.style_notes.present?
      # Extract key adjectives (professional, casual, modern, etc.)
      style_keywords = extract_style_keywords(@recommendation.style_notes)
      parts.concat(style_keywords)
    end

    # Join and clean up
    parts.compact.join(' ').gsub('-', ' ')
  end

  def extract_style_keywords(style_notes)
    # Extract meaningful style keywords (avoid common words)
    common_words = %w[the a an and or but for with should would could can will]

    words = style_notes.downcase
                       .gsub(/[^a-z\s]/, '')
                       .split
                       .uniq
                       .reject { |word| common_words.include?(word) || word.length < 4 }

    # Limit to first 2-3 style keywords
    words.first(2)
  end

  def search_amazon_rapidapi(query, limit)
    uri = URI("#{RAPIDAPI_BASE_URL}/search")
    params = {
      query: query,
      page: '1',
      country: @marketplace,
      sort_by: 'RELEVANCE',
      product_condition: 'ALL'
    }
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    http.open_timeout = 5

    request = Net::HTTP::Get.new(uri)
    request['X-RapidAPI-Key'] = @rapidapi_key
    request['X-RapidAPI-Host'] = @rapidapi_host

    Rails.logger.info("Making RapidAPI request: #{uri}")

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("RapidAPI request failed: #{response.code} - #{response.body}")
      raise MatchingError, "RapidAPI request failed with status #{response.code}"
    end

    # Parse response
    parse_rapidapi_response(response.body, limit)
  rescue Net::ReadTimeout, Net::OpenTimeout => e
    Rails.logger.error("RapidAPI timeout: #{e.message}")
    raise MatchingError, "Amazon API request timed out: #{e.message}"
  rescue StandardError => e
    Rails.logger.error("RapidAPI search error: #{e.message}")
    raise MatchingError, "Amazon API request failed: #{e.message}"
  end

  def determine_category_id
    # Map category to Amazon category for better search results
    category = @recommendation.category&.downcase || ''

    if category.include?('shoe') || category.include?('boot') || category.include?('sneaker')
      'fashion-shoes'
    elsif category.include?('clothing') || category.include?('shirt') || category.include?('pant') ||
          category.include?('dress') || category.include?('jacket') || category.include?('blazer') ||
          category.include?('jeans') || category.include?('sweater') || category.include?('coat')
      'fashion-clothing'
    elsif category.include?('jewelry') || category.include?('watch')
      'fashion-jewelry'
    elsif category.include?('bag') || category.include?('luggage') || category.include?('wallet')
      'fashion-bags'
    else
      'fashion' # Search all fashion if not sure
    end
  end

  def parse_rapidapi_response(response_body, limit)
    products = []

    parsed = JSON.parse(response_body)

    # Real-Time Amazon Data API response structure: { status: "OK", data: { products: [...] } }
    if parsed['status'] == 'OK' && parsed['data']
      items = parsed['data']['products'] || []
    else
      # Fallback for other structures
      items = parsed['products'] || parsed['results'] || parsed['data'] || []
    end

    Rails.logger.debug("RapidAPI response: total items received = #{items.count}")

    return [] unless items.is_a?(Array)

    items.first(limit).each do |item|
      product = parse_rapidapi_item(item)
      if product
        products << product
        Rails.logger.debug("Successfully parsed product: ASIN=#{product['asin']}, Price=$#{product['price']}")
      else
        Rails.logger.debug("Failed to parse item: ASIN=#{item['asin'] || 'N/A'}")
      end
    end

    Rails.logger.debug("Total products before budget filter: #{products.count}")

    # Filter by budget range if specified
    filtered_products = filter_by_budget(products)
    Rails.logger.debug("Total products after budget filter: #{filtered_products.count}")

    filtered_products
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing RapidAPI JSON response: #{e.message}")
    []
  rescue StandardError => e
    Rails.logger.error("Error parsing RapidAPI response: #{e.message}")
    []
  end

  def parse_rapidapi_item(item)
    # Extract ASIN (required)
    asin = item['asin'] || item['ASIN']
    return nil unless asin.present?

    # Extract title (Real-Time Amazon Data uses 'product_title')
    title = item['product_title'] || item['title'] || item['name']
    return nil unless title.present?

    # Extract price information
    price_info = extract_rapidapi_price(item)
    return nil unless price_info # Skip items without prices

    # Extract image URL (Real-Time Amazon Data uses 'product_photo')
    image_url = item['product_photo'] || item['image'] || item['image_url'] || item['thumbnail'] ||
                item.dig('images', 0) || item.dig('main_image', 'url')

    # Build affiliate URL with partner tag
    product_url = item['product_url'] || item['url'] || "https://www.amazon.com/dp/#{asin}"

    # Ensure affiliate tag is included
    affiliate_url = if product_url.include?('tag=')
                      product_url
                    else
                      separator = product_url.include?('?') ? '&' : '?'
                      "#{product_url}#{separator}tag=#{@partner_tag}"
                    end

    # Extract rating and review count (Real-Time Amazon Data uses 'product_star_rating', 'product_num_ratings')
    rating = item['product_star_rating'] || item['rating'] || item['stars']
    rating = rating.to_f if rating.is_a?(String)

    review_count = item['product_num_ratings'] || item['reviews_count'] || item['ratings_total'] || item['review_count']
    review_count = review_count.to_i if review_count.is_a?(String)

    # Return with string keys to match JSONB storage format
    {
      "asin" => asin,
      "title" => title,
      "price" => price_info[:price],
      "currency" => price_info[:currency],
      "image_url" => image_url,
      "affiliate_url" => affiliate_url,
      "rating" => rating,
      "review_count" => review_count
    }
  rescue StandardError => e
    Rails.logger.error("Error parsing RapidAPI item: #{e.message}")
    nil
  end

  def extract_rapidapi_price(item)
    price_data = {
      price: nil,
      currency: 'USD'
    }

    # Try different price field names
    price_value = item['price'] || item['product_price'] ||
                  item.dig('price', 'value') || item.dig('price', 'raw')

    if price_value.present?
      # Parse price - could be "$39.99" or "39.99" or 39.99
      if price_value.is_a?(String)
        price_data[:price] = parse_display_amount(price_value)
      elsif price_value.is_a?(Numeric)
        price_data[:price] = format('%.2f', price_value)
      end
    end

    # Try to get currency if available
    currency = item['currency'] || item.dig('price', 'currency')
    price_data[:currency] = currency if currency.present?

    # Return nil if no price found
    return nil unless price_data[:price].present?

    price_data
  rescue StandardError => e
    Rails.logger.error("Error extracting price from RapidAPI: #{e.message}")
    nil
  end

  def parse_display_amount(display_amount)
    return nil unless display_amount.present?

    # DisplayAmount comes as "$39.99" or "£39.99" etc.
    # Strip currency symbols and parse the number
    display_amount.to_s.gsub(/[^\d.]/, '')
  end

  def filter_by_budget(products)
    budget_range = @recommendation.budget_range&.to_sym
    Rails.logger.debug("filter_by_budget: budget_range = #{budget_range.inspect}, valid? = #{BUDGET_PRICE_RANGES.key?(budget_range)}")

    return products unless budget_range && BUDGET_PRICE_RANGES.key?(budget_range)

    range = BUDGET_PRICE_RANGES[budget_range]
    min_price = range[:min]
    max_price = range[:max]

    Rails.logger.debug("Budget filter: min=$#{min_price}, max=$#{max_price || 'unlimited'}")

    products.select do |product|
      # Get price from our stored data
      price_str = product["price"] || product[:price]
      next false unless price_str

      price = price_str.to_f

      # Check if within range
      within_min = min_price.nil? || price >= min_price
      within_max = max_price.nil? || price <= max_price

      in_range = within_min && within_max
      Rails.logger.debug("  Product price $#{price}: in_range=#{in_range} (min_ok=#{within_min}, max_ok=#{within_max})")

      in_range
    end
  end
end
