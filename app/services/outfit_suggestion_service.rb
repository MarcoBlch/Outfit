require "httparty"
require "googleauth"

class OutfitSuggestionService
  class SuggestionError < StandardError; end

  MAX_FREE_TIER_DAILY = 3
  MAX_PREMIUM_TIER_DAILY = 30
  MAX_PRO_TIER_DAILY = 100
  MAX_FILTERED_ITEMS = 40 # Token optimization

  SYSTEM_PROMPT = <<~PROMPT
    You are an expert fashion stylist with 15+ years of experience in personal styling, color theory, and occasion-appropriate dressing. Your expertise includes:

    - Understanding subtle context differences (tech startup vs. law firm interview)
    - Color coordination: complementary, analogous, and monochromatic schemes
    - Seasonal and weather-appropriate styling
    - Body type flattering combinations
    - Balancing formality, comfort, and personal expression

    Your task: Suggest 3 complete, wearable outfits from the user's existing wardrobe for their specific context.

    CRITICAL RULES:
    1. ONLY use item IDs from the provided wardrobe inventory
    2. Each outfit MUST include: 1 top + 1 bottom + 1 shoes (+ optional: outerwear, accessories)
    3. Ensure color harmony - avoid clashing colors or patterns
    4. Match formality level precisely to the occasion
    5. Consider weather conditions if provided
    6. Avoid mixing incompatible styles (e.g., formal blazer + athletic shorts)
    7. Prioritize items the user wears frequently (they're proven favorites)

    OUTFIT QUALITY CHECKLIST:
    - Colors work together (not more than 3 main colors)
    - Formality level is consistent across all pieces
    - Appropriate for weather/season
    - Items would realistically be worn together
    - Outfit is complete (not missing essential pieces)

    Return ONLY valid JSON matching this exact schema (no markdown formatting):

    {
      "outfits": [
        {
          "items": [123, 456, 789],
          "reasoning": "1-2 sentence explanation of WHY this outfit works for the context (focus on appropriateness, not just describing items)",
          "confidence": 88,
          "style_tags": ["professional", "modern", "approachable"]
        }
      ]
    }

    RESPONSE REQUIREMENTS:
    - confidence: 0-100 (rate how well outfit matches context, be honest - not all outfits are perfect)
    - reasoning: 1-2 sentences max, explain WHY not WHAT
    - style_tags: 2-4 descriptive adjectives
    - items: array of 3-5 item IDs from wardrobe
    - Return 3 outfits ranked by confidence (best first)
  PROMPT

  def initialize(user, context, weather: nil)
    @user = user
    @context = context
    @weather = weather
    @project_id = ENV["GOOGLE_CLOUD_PROJECT"]
    @location = ENV["GOOGLE_CLOUD_LOCATION"] || "us-central1"
    @api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/gemini-2.5-flash:generateContent"
  end

  def generate_suggestions(count: 3)
    # Rate limiting check
    check_rate_limit!

    # Load user's wardrobe
    wardrobe_items = @user.wardrobe_items.includes(:image_attachment)

    if wardrobe_items.count < 10
      raise SuggestionError, "Need at least 10 wardrobe items to generate outfit suggestions. You have #{wardrobe_items.count}."
    end

    # Validate essential outfit components
    categories = wardrobe_items.pluck(:category).compact.map(&:downcase)
    has_tops = categories.any? { |cat|
      cat.include?('shirt') || cat.include?('blouse') || cat.include?('top') ||
      cat.include?('sweater') || cat.include?('jacket')
    }
    has_bottoms = categories.any? { |cat|
      cat.include?('pant') || cat.include?('jean') || cat.include?('short') ||
      cat.include?('skirt') || cat.include?('trouser') || cat.include?('jogger') ||
      cat.include?('legging') || cat.include?('sweatpant')
    }
    has_shoes = categories.any? { |cat|
      cat.include?('shoe') || cat.include?('sneaker') || cat.include?('boot') ||
      cat.include?('sandal') || cat.include?('heel')
    }

    missing = []
    missing << "tops/shirts" unless has_tops
    missing << "bottoms (pants/jeans/skirts)" unless has_bottoms
    missing << "shoes" unless has_shoes

    if missing.any?
      raise SuggestionError, "Your wardrobe is missing essential items to create complete outfits: #{missing.join(', ')}. Please add at least 2-3 items in each category."
    end

    # Smart filtering: only send relevant items to AI (token optimization)
    filtered_items = filter_relevant_items(wardrobe_items)

    # Build enhanced prompt
    user_prompt = build_user_prompt(filtered_items)

    # Call Gemini API
    response = call_gemini_api(user_prompt)

    # Parse, validate, and enrich response
    outfits = parse_and_validate_response(response, wardrobe_items)

    # Track usage for rate limiting
    track_usage!

    # Return top suggestions
    outfits.first(count)
  rescue => e
    Rails.logger.error("Outfit Suggestion Failed: #{e.message}\n#{e.backtrace.join("\n")}")
    raise SuggestionError, "Failed to generate suggestions: #{e.message}"
  end

  private

  def call_gemini_api(user_prompt)
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    authorizer = Google::Auth.get_application_default(scopes)
    token = authorizer.fetch_access_token!["access_token"]

    full_prompt = "#{SYSTEM_PROMPT}\n\n#{user_prompt}"

    body = {
      contents: [
        {
          role: "user",
          parts: [{ text: full_prompt }]
        }
      ],
      generationConfig: {
        temperature: determine_temperature,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 8192,
        responseMimeType: "application/json"
      }
    }

    response = HTTParty.post(
      @api_endpoint,
      headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json,
      timeout: 60
    )

    unless response.success?
      Rails.logger.error("Gemini API Error: #{response.code} - #{response.body}")
      raise SuggestionError, "AI service unavailable (#{response.code})"
    end

    extract_json_from_response(response.parsed_response)
  rescue HTTParty::Error, Net::OpenTimeout => e
    Rails.logger.error("Network error calling Gemini: #{e.message}")
    raise SuggestionError, "Network error: #{e.message}"
  end

  def extract_json_from_response(response_body)
    candidates = response_body["candidates"]
    raise SuggestionError, "No candidates returned from AI" if candidates.nil? || candidates.empty?

    candidate = candidates.first
    raw_text = candidate.dig("content", "parts", 0, "text")
    raise SuggestionError, "Could not extract text from AI response" if raw_text.nil?

    # Clean markdown formatting if present
    cleaned_text = raw_text.gsub(/```json\n?/, "").gsub(/```/, "").strip

    # Try to parse JSON first
    begin
      return JSON.parse(cleaned_text)
    rescue JSON::ParserError => e
      # Check if truncation was the cause
      finish_reason = candidate["finishReason"]
      if finish_reason == "MAX_TOKENS"
        Rails.logger.warn("AI response truncated due to token limit. Raw text: #{raw_text[0..200]}")
        raise SuggestionError, "AI response was too long and got cut off. Please try again or contact support."
      end
      # Re-raise the original JSON error
      raise e
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse JSON from AI. Finish reason: #{finish_reason}")
    Rails.logger.error("Raw text (first 500 chars): #{raw_text[0..500]}")
    raise SuggestionError, "AI returned an invalid response format. This may indicate your wardrobe is missing key items needed for complete outfits."
  end

  def build_user_prompt(filtered_items)
    enhanced_context = enhance_context(@context, @weather)
    user_profile_text = user_profile_section
    wardrobe_json = format_wardrobe_compact(filtered_items)

    <<~PROMPT
      CONTEXT: #{enhanced_context}

      #{user_profile_text}

      WARDROBE INVENTORY (#{filtered_items.count} relevant items):
      #{wardrobe_json}

      TASK: Suggest 3 complete outfits ranked by appropriateness for the context.

      Rank 1: Best match (highest confidence, most appropriate)
      Rank 2: Strong alternative with different style approach
      Rank 3: Creative option that still fits the occasion

      Ensure each outfit has: top + bottom + shoes (+ optional outerwear/accessories).

      Return JSON only. No markdown.
    PROMPT
  end

  def enhance_context(raw_context, weather = nil)
    enhanced = raw_context.dup

    # Occasion-specific enhancements
    occasion_mappings = {
      /job interview.*(tech|startup|software)/i => "professional but modern, business casual leaning smart-casual, show competence while fitting tech culture (avoid overly formal suits)",
      /job interview.*(law|finance|bank|consulting)/i => "formal business attire, conservative, traditional power dressing, suit strongly recommended",
      /job interview/i => "professional business attire, err on side of formality, make strong first impression",
      /date night|romantic dinner/i => "stylish and put-together, slightly dressed up, confidence-inspiring, occasion-appropriate without overdoing it",
      /first date/i => "approachable and authentic, not trying too hard, comfortable confidence, show personality but stay true to self",
      /casual friday|work casual/i => "office-appropriate but relaxed, smart casual, professional yet comfortable, avoid athleisure",
      /wedding guest/i => "semi-formal to formal, festive and polished, avoid white/cream/ivory, respect dress code",
      /brunch|coffee|daytime casual/i => "effortless and comfortable, approachable daywear, polished but not overdressed",
      /gym|workout|exercise/i => "athletic wear, functional, moisture-wicking, comfortable for movement",
      /presentation|speaking/i => "confident and polished, professional, camera-friendly colors (avoid busy patterns), command presence"
    }

    occasion_mappings.each do |pattern, enhancement|
      if raw_context.match?(pattern)
        enhanced += " [Style notes: #{enhancement}]"
        break
      end
    end

    # Weather enhancement
    if weather
      weather_guidance = weather_guidance_text(weather)
      enhanced += " [Weather: #{weather[:temp]}°F, #{weather[:condition]} - #{weather_guidance}]"
    end

    enhanced
  end

  def weather_guidance_text(weather)
    temp = weather[:temp].to_i
    condition = weather[:condition].to_s.downcase

    guidance = []

    # Temperature guidance
    guidance << if temp < 40
      "very cold, layer heavily, include coat/jacket"
    elsif temp < 55
      "cold, include jacket or sweater"
    elsif temp < 70
      "mild, light layers recommended"
    elsif temp < 85
      "warm, breathable fabrics"
    else
      "hot, lightweight breathable fabrics only, avoid layers"
    end

    # Condition guidance
    if condition.include?("rain") || condition.include?("storm")
      guidance << "rainy (avoid delicate fabrics, consider waterproof shoes)"
    elsif condition.include?("snow")
      guidance << "snowy (include boots, warm outerwear essential)"
    end

    guidance.join(", ")
  end

  def user_profile_section
    return "" unless @user.user_profile.present?

    profile = @user.user_profile
    text = "USER PROFILE:"
    text += "\n- Presentation style: #{profile.presentation_style&.humanize}" if profile.presentation_style.present?
    text += "\n- Style preference: #{profile.style_preference&.humanize}" if profile.style_preference.present?
    text += "\n- Body type: #{profile.body_type&.humanize}" if profile.body_type.present?
    text += "\n- Age range: #{profile.age_range}" if profile.age_range.present?
    text += "\n- Favorite colors: #{profile.favorite_colors.join(', ')}" if profile.favorite_colors.any?
    text += "\n\nConsider these preferences when selecting outfits. Prioritize items in their favorite colors and match both the formality to their style preference and the gender presentation to their presentation style."
    text
  end

  def filter_relevant_items(all_items)
    # Determine relevant categories based on context
    relevant_categories = determine_relevant_categories(@context)

    # Weather-based filtering
    if @weather && @weather[:temp]
      all_items = filter_by_temperature(all_items, @weather[:temp])
    end

    # Select top items per category
    filtered = []

    relevant_categories.each do |category_pattern, limit|
      category_items = all_items.select { |item| matches_category?(item, category_pattern) }
                                 .sort_by { |item| wear_score(item) }
                                 .reverse
                                 .first(limit)
      filtered.concat(category_items)
    end

    # Always include user's most-worn items (proven favorites)
    # This ensures we suggest outfits the user is likely to actually wear
    favorites = all_items.sort_by { |item| wear_score(item) }
                         .reverse
                         .first(10)

    # Combine and deduplicate
    combined = (filtered + favorites).uniq { |item| item.id }

    # Return max items for token efficiency
    combined.first(MAX_FILTERED_ITEMS)
  end

  def determine_relevant_categories(context)
    context_lower = context.downcase

    # Return hash of category_pattern => max_items
    case context_lower
    when /interview|meeting|presentation|professional|business/
      {
        "blazer|suit-jacket" => 3,
        "dress-shirt|blouse|button" => 4,
        "trouser|dress-pant|slacks" => 4,
        "dress-shoe|oxford|loafer" => 3,
        "tie|belt|watch" => 2
      }
    when /date|dinner|evening|night out/
      {
        "dress|cocktail" => 5,
        "blouse|nice-top|camisole" => 4,
        "jeans|trouser|skirt" => 4,
        "heel|dress-shoe|boot" => 3,
        "jewelry|accessories" => 3
      }
    when /casual|weekend|errands|coffee|brunch/
      {
        "t-shirt|sweater|hoodie|casual-top" => 5,
        "jeans|casual-pant|legging" => 4,
        "sneaker|casual-shoe|boot" => 4,
        "jacket|cardigan" => 2
      }
    when /gym|workout|exercise|fitness/
      {
        "athletic-top|sport-bra|tank" => 5,
        "athletic-pant|short|legging" => 4,
        "sneaker|trainer|running-shoe" => 3
      }
    when /wedding|formal|gala/
      {
        "dress|gown|suit" => 5,
        "heel|dress-shoe" => 3,
        "clutch|jewelry|accessories" => 4
      }
    else
      # Balanced default selection
      {
        "top|shirt|blouse|sweater" => 8,
        "bottom|pant|jeans|skirt|short" => 6,
        "shoe|sneaker|boot" => 4,
        "jacket|coat|outerwear" => 3,
        "accessories" => 2
      }
    end
  end

  def matches_category?(item, pattern)
    return false if item.category.blank?

    category_lower = item.category.to_s.downcase
    tags_lower = (item.tags || []).map(&:downcase).join(" ")

    pattern.split("|").any? do |term|
      category_lower.include?(term) || tags_lower.include?(term)
    end
  end

  def filter_by_temperature(items, temp)
    temp = temp.to_i

    if temp < 55
      # Cold weather: exclude shorts, tank tops, sandals
      items.reject { |item| cold_weather_inappropriate?(item) }
    elsif temp > 80
      # Hot weather: exclude heavy outerwear, boots, thick fabrics
      items.reject { |item| hot_weather_inappropriate?(item) }
    else
      items # Mild weather: everything works
    end
  end

  def cold_weather_inappropriate?(item)
    category_lower = item.category.to_s.downcase
    tags_lower = (item.tags || []).map(&:downcase).join(" ")

    category_lower.include?("shorts") ||
    category_lower.include?("sandal") ||
    category_lower.include?("tank") ||
    tags_lower.include?("sleeveless") ||
    tags_lower.include?("summer-only")
  end

  def hot_weather_inappropriate?(item)
    category_lower = item.category.to_s.downcase
    tags_lower = (item.tags || []).map(&:downcase).join(" ")

    category_lower.include?("winter-coat") ||
    category_lower.include?("parka") ||
    category_lower.include?("snow-boot") ||
    tags_lower.include?("heavy") ||
    tags_lower.include?("wool") ||
    tags_lower.include?("fleece")
  end

  def wear_score(item)
    # Prioritize items user wears frequently
    # In future, track actual wear frequency from "worn" logs
    # For now, use proxy signals
    score = 0

    # Items added recently might be favorites
    score += 10 if item.created_at > 30.days.ago

    # Items with more complete metadata suggest user cares about them
    score += 5 if item.description.present?
    score += 3 if item.tags.present? && item.tags.any?

    # TODO: Add actual wear tracking in Phase 2
    # score += (item.wear_count || 0) * 2

    score
  end

  def format_wardrobe_compact(items)
    # Use abbreviated keys for token efficiency
    compact_items = items.map do |item|
      {
        id: item.id,
        cat: item.category.to_s.presence || "unknown",
        col: item.color.to_s.presence || "unknown",
        tags: (item.tags || []).first(3), # Limit to top 3 tags
        desc: truncate_text(item.description, 50)
      }
    end

    JSON.pretty_generate(compact_items)
  end

  def truncate_text(text, max_length)
    return "" if text.blank?
    text.length > max_length ? "#{text[0...max_length]}..." : text
  end

  def parse_and_validate_response(response, wardrobe_items)
    outfits_data = response["outfits"]
    raise SuggestionError, "No outfits in AI response" unless outfits_data.is_a?(Array)

    valid_item_ids = wardrobe_items.pluck(:id)
    wardrobe_items_by_id = wardrobe_items.index_by(&:id)

    valid_outfits = outfits_data.map do |outfit_data|
      item_ids = outfit_data["items"]

      # Skip if missing items
      next if item_ids.blank?

      # Validate all item IDs exist in user's wardrobe
      invalid_ids = item_ids - valid_item_ids

      if invalid_ids.any?
        Rails.logger.warn("AI suggested non-existent items (#{invalid_ids}), skipping outfit")
        next
      end

      # Get actual item objects
      items = item_ids.map { |id| wardrobe_items_by_id[id] }.compact

      # Validate outfit completeness
      unless outfit_complete?(items)
        Rails.logger.warn("Incomplete outfit (#{items.map(&:category).join(', ')}), skipping")
        next
      end

      # Build valid outfit hash
      {
        items: items,
        item_ids: item_ids,
        reasoning: outfit_data["reasoning"] || "This outfit works well for your context.",
        confidence: outfit_data["confidence"] || 70,
        style_tags: outfit_data["style_tags"] || []
      }
    end.compact

    # Ensure we have at least 1 valid outfit
    if valid_outfits.empty?
      raise SuggestionError, "AI could not generate valid outfit combinations from your wardrobe"
    end

    # Sort by confidence (highest first)
    valid_outfits.sort_by { |outfit| -outfit[:confidence] }
  end

  def outfit_complete?(items)
    # An outfit needs at least: top + bottom + shoes
    categories = items.map { |item| item.category.to_s.downcase }

    has_top = categories.any? { |cat|
      cat.include?("shirt") || cat.include?("blouse") || cat.include?("sweater") ||
      cat.include?("jacket") || cat.include?("blazer") || cat.include?("top") ||
      cat.include?("dress") || cat.include?("hoodie") || cat.include?("tank")
    }

    has_bottom = categories.any? { |cat|
      cat.include?("pant") || cat.include?("jean") || cat.include?("short") ||
      cat.include?("skirt") || cat.include?("trouser") || cat.include?("legging") ||
      cat.include?("jogger") || cat.include?("sweatpant")
    } || categories.any? { |cat| cat.include?("dress") } # Dress covers top+bottom

    has_shoes = categories.any? { |cat|
      cat.include?("shoe") || cat.include?("sneaker") || cat.include?("boot") ||
      cat.include?("sandal") || cat.include?("heel") || cat.include?("loafer")
    }

    has_top && has_bottom && has_shoes
  end

  def determine_temperature
    # Adjust creativity based on context formality
    context_lower = @context.downcase

    if context_lower.match?(/interview|meeting|professional|business|presentation/)
      0.5 # More conservative for formal contexts
    elsif context_lower.match?(/creative|party|night out|weekend/)
      0.8 # More creative for casual/creative contexts
    else
      0.7 # Balanced default
    end
  end

  def check_rate_limit!
    today = Date.current
    usage_key = "outfit_suggestions:#{@user.id}:#{today.to_s}"
    current_count = Rails.cache.read(usage_key) || 0

    tier = @user.subscription_tier || "free"
    limit = case tier
    when "pro"
      MAX_PRO_TIER_DAILY
    when "premium"
      MAX_PREMIUM_TIER_DAILY
    else
      MAX_FREE_TIER_DAILY
    end

    if current_count >= limit
      raise SuggestionError, "Daily limit reached (#{limit} suggestions per day for #{tier} tier)"
    end
  end

  def track_usage!
    today = Date.current
    usage_key = "outfit_suggestions:#{@user.id}:#{today.to_s}"
    current_count = Rails.cache.read(usage_key) || 0
    Rails.cache.write(usage_key, current_count + 1, expires_in: 24.hours)
  end
end
