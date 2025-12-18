# frozen_string_literal: true

require 'paapi'

class AmazonProductMatcher
  class MatchingError < StandardError; end

  # Budget range price mappings (in cents)
  BUDGET_PRICE_RANGES = {
    budget: { min: 0, max: 5000 },        # $0-50
    mid_range: { min: 3000, max: 15000 }, # $30-150
    premium: { min: 10000, max: 30000 },  # $100-300
    luxury: { min: 25000, max: nil }      # $250+
  }.freeze

  # Resources to request from Amazon PA-API
  RESOURCES = [
    'ItemInfo.Title',
    'ItemInfo.Features',
    'Offers.Listings.Price',
    'Offers.Listings.Condition',
    'Offers.Summaries.LowestPrice',
    'Images.Primary.Medium',
    'Images.Primary.Large'
  ].freeze

  def initialize(product_recommendation)
    @recommendation = product_recommendation
    @access_key = ENV['AMAZON_ACCESS_KEY']
    @secret_key = ENV['AMAZON_SECRET_KEY']
    @partner_tag = ENV['AMAZON_ASSOCIATE_TAG'] || ENV['AMAZON_PARTNER_TAG']
    @partner_type = ENV['AMAZON_PARTNER_TYPE'] || 'Associates'
    @marketplace = ENV['AMAZON_MARKETPLACE'] || 'www.amazon.com'
  end

  def find_matching_products(limit: 5)
    validate_credentials!

    Rails.logger.info("Starting Amazon product search for ProductRecommendation ##{@recommendation.id}")

    # Build search query
    search_query = build_search_query
    Rails.logger.info("Search query: #{search_query}")

    # Search Amazon PA-API
    products = search_amazon(search_query, limit)

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
    missing_configs << 'AMAZON_ACCESS_KEY' if @access_key.blank?
    missing_configs << 'AMAZON_SECRET_KEY' if @secret_key.blank?
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

  def search_amazon(query, limit)
    # Configure PA-API client
    market = determine_market
    client = Paapi::Client.new(
      access_key: @access_key,
      secret_key: @secret_key,
      market: market,
      partner_tag: @partner_tag
    )

    # Build search request
    response = client.search_items(
      keywords: query,
      item_count: [limit, 10].min, # PA-API allows max 10 items per request
      resources: RESOURCES,
      search_index: determine_search_index
    )

    # Parse response
    parse_amazon_response(response)
  rescue StandardError => e
    Rails.logger.error("PA-API search error: #{e.message}")
    raise MatchingError, "Amazon API request failed: #{e.message}"
  end

  def determine_market
    # Map marketplace domain to market code
    case @marketplace
    when 'www.amazon.com' then :us
    when 'www.amazon.co.uk' then :uk
    when 'www.amazon.de' then :de
    when 'www.amazon.fr' then :fr
    when 'www.amazon.co.jp' then :jp
    when 'www.amazon.ca' then :ca
    when 'www.amazon.com.au' then :au
    when 'www.amazon.in' then :in
    when 'www.amazon.it' then :it
    when 'www.amazon.es' then :es
    when 'www.amazon.com.mx' then :mx
    when 'www.amazon.com.br' then :br
    else :us # Default to US
    end
  end

  def determine_search_index
    # Map category to Amazon SearchIndex
    category = @recommendation.category&.downcase || ''

    if category.include?('shoe') || category.include?('boot') || category.include?('sneaker')
      'Shoes'
    elsif category.include?('clothing') || category.include?('shirt') || category.include?('pant') ||
          category.include?('dress') || category.include?('jacket') || category.include?('blazer') ||
          category.include?('jeans') || category.include?('sweater') || category.include?('coat')
      'Fashion'
    elsif category.include?('jewelry') || category.include?('watch') || category.include?('accessory')
      'Jewelry'
    elsif category.include?('bag') || category.include?('luggage') || category.include?('wallet')
      'Luggage'
    else
      'All' # Search all categories if not sure
    end
  end

  def parse_amazon_response(response)
    products = []

    # Handle both hash and object responses
    items = if response.is_a?(Hash)
              response.dig('SearchResult', 'Items')
            elsif response.respond_to?(:search_result) && response.search_result.respond_to?(:items)
              response.search_result.items
            end

    return [] unless items.is_a?(Array)

    items.each do |item|
      product = parse_item(item)
      products << product if product
    end

    # Filter by budget range if specified
    filter_by_budget(products)
  rescue StandardError => e
    Rails.logger.error("Error parsing PA-API response: #{e.message}")
    []
  end

  def parse_item(item)
    # Extract ASIN (required) - handle both hash and object
    asin = item.is_a?(Hash) ? item['ASIN'] : item.try(:asin)
    return nil unless asin.present?

    # Extract title - handle both hash and object
    title = if item.is_a?(Hash)
              item.dig('ItemInfo', 'Title', 'DisplayValue')
            else
              item.try(:item_info)&.try(:title)&.try(:display_value)
            end

    return nil unless title.present?

    # Extract price information
    price_info = extract_price(item)
    return nil unless price_info # Skip items without prices

    # Extract image URL - handle both hash and object
    image_url = if item.is_a?(Hash)
                  item.dig('Images', 'Primary', 'Large', 'URL') ||
                    item.dig('Images', 'Primary', 'Medium', 'URL')
                else
                  item.try(:images)&.try(:primary)&.try(:large)&.try(:url) ||
                    item.try(:images)&.try(:primary)&.try(:medium)&.try(:url)
                end

    # Build affiliate URL with partner tag
    base_domain = @marketplace.start_with?('www.') ? @marketplace : "www.#{@marketplace}"
    affiliate_url = "https://#{base_domain}/dp/#{asin}?tag=#{@partner_tag}"

    # Extract detail page URL if available (already includes partner tag)
    detail_url = item.is_a?(Hash) ? item['DetailPageURL'] : item.try(:detail_page_url)
    affiliate_url = detail_url if detail_url.present?

    # Return with string keys to match JSONB storage format
    {
      "asin" => asin,
      "title" => title,
      "price" => price_info[:price],
      "currency" => price_info[:currency],
      "image_url" => image_url,
      "affiliate_url" => affiliate_url,
      "rating" => nil, # Rating not always available via PA-API
      "review_count" => nil # Review count not always available via PA-API
    }
  rescue StandardError => e
    Rails.logger.error("Error parsing Amazon item: #{e.message}")
    nil
  end

  def extract_price(item)
    price_data = {
      price: nil,
      currency: 'USD',
      amount_cents: nil
    }

    # Handle both hash and object responses
    if item.is_a?(Hash)
      # Try to get the lowest price from Offers.Summaries
      lowest_price = item.dig('Offers', 'Summaries', 0, 'LowestPrice')
      if lowest_price
        price_data[:price] = parse_display_amount(lowest_price['DisplayAmount']) || format_price_amount(lowest_price['Amount'], lowest_price['Currency'])
        price_data[:currency] = lowest_price['Currency'] || 'USD'
        price_data[:amount_cents] = lowest_price['Amount'] || calculate_amount_cents(price_data[:price])
      end

      # Try to get price from first listing if no summary price
      if price_data[:price].nil?
        listing_price = item.dig('Offers', 'Listings', 0, 'Price')
        if listing_price
          price_data[:price] = parse_display_amount(listing_price['DisplayAmount']) || format_price_amount(listing_price['Amount'], listing_price['Currency'])
          price_data[:currency] = listing_price['Currency'] || 'USD'
          price_data[:amount_cents] = listing_price['Amount'] || calculate_amount_cents(price_data[:price])
        end
      end
    else
      # Object-based response
      listing = item.try(:offers)&.try(:listings)&.first
      if listing&.try(:price)
        price_obj = listing.price
        price_amount = price_obj.try(:amount)
        currency = price_obj.try(:currency) || 'USD'

        if price_amount
          price_data[:price] = format('%.2f', price_amount)
          price_data[:currency] = currency
          price_data[:amount_cents] = (price_amount * 100).to_i
        end
      end
    end

    # Return nil if no price found
    return nil unless price_data[:price].present?

    price_data
  rescue StandardError => e
    Rails.logger.error("Error extracting price: #{e.message}")
    nil
  end

  def parse_display_amount(display_amount)
    return nil unless display_amount.present?

    # DisplayAmount comes as "$39.99" or "£39.99" etc.
    # Strip currency symbols and parse the number
    display_amount.to_s.gsub(/[^\d.]/, '')
  end

  def calculate_amount_cents(price_string)
    return nil unless price_string.present?

    (price_string.to_f * 100).to_i
  end

  def format_price_amount(amount, currency)
    return nil unless amount

    # Amount is typically in lowest currency unit (cents for USD)
    # Format as decimal with 2 places
    format('%.2f', amount.to_f / 100.0)
  rescue StandardError
    nil
  end

  def filter_by_budget(products)
    budget_range = @recommendation.budget_range&.to_sym
    return products unless budget_range && BUDGET_PRICE_RANGES.key?(budget_range)

    range = BUDGET_PRICE_RANGES[budget_range]
    min_price = range[:min]
    max_price = range[:max]

    products.select do |product|
      # Get price in cents from our stored data (handle both symbol and string keys)
      price_str = product["price"] || product[:price]
      next false unless price_str

      price_cents = (price_str.to_f * 100).to_i

      # Check if within range
      within_min = min_price.nil? || price_cents >= min_price
      within_max = max_price.nil? || price_cents <= max_price

      within_min && within_max
    end
  end
end
