# frozen_string_literal: true

require 'httparty'
require 'googleauth'

class MissingItemDetector
  class DetectionError < StandardError; end

  SYSTEM_PROMPT = <<~PROMPT
    You are an expert wardrobe consultant specializing in identifying missing essential items that prevent creating complete, stylish outfits.

    Your expertise includes:
    - Understanding wardrobe gaps that limit outfit versatility
    - Recommending items that maximize wardrobe combinations
    - Considering user's style, age, and presentation preferences
    - Providing practical, budget-conscious suggestions
    - Prioritizing items based on versatility and user profile

    Your task: Analyze the user's existing wardrobe and outfit context to identify 1-3 missing items that would significantly improve their ability to create appropriate outfits.

    CRITICAL RULES:
    1. Only suggest items that are genuinely missing from the wardrobe
    2. Prioritize versatile pieces that work with multiple existing items
    3. Consider the outfit context and what items would complete the suggested outfits
    4. Match suggestions to user's style preference, age range, and presentation style
    5. Suggest items in user's favorite colors when appropriate
    6. Be specific with descriptions (not just "black pants" but "black slim-fit dress pants")
    7. Provide practical budget ranges based on item type and quality
    8. Focus on filling critical gaps, not just adding variety

    QUALITY CHECKLIST:
    - Each suggestion fills a real gap in the wardrobe
    - Suggested items would work with existing wardrobe pieces
    - Suggestions align with user's style and presentation preferences
    - Budget ranges are realistic for the item type
    - Priority levels accurately reflect importance
    - Reasoning clearly explains why the item is needed

    Return ONLY valid JSON matching this exact schema (no markdown formatting):

    {
      "missing_items": [
        {
          "category": "dress-pants",
          "description": "Black slim-fit dress pants in a breathable wool-blend fabric",
          "color_preference": "black",
          "style_notes": "Professional, modern cut with slight taper. Should work for interviews and business meetings.",
          "reasoning": "Would complete professional outfits with existing dress shirts and blazers. Currently lacking formal bottom options.",
          "priority": "high",
          "budget_range": "$60-120"
        }
      ]
    }

    FIELD REQUIREMENTS:
    - category: Specific category (e.g., "dress-pants", "blazer", "loafers")
    - description: Detailed description including fabric, fit, and key features
    - color_preference: Specific color that works with existing wardrobe (consider user's favorite colors)
    - style_notes: Style guidance and how it fits the user's aesthetic
    - reasoning: 1-2 sentences explaining WHY this item is needed
    - priority: "high", "medium", or "low" based on how critical the gap is
    - budget_range: Realistic price range (e.g., "$40-80", "$100-200")

    Return 1-3 suggestions ordered by priority (highest first). If wardrobe is complete, return empty array.
  PROMPT

  def initialize(user, outfit_context:, suggested_outfits: [])
    @user = user
    @outfit_context = outfit_context
    @suggested_outfits = suggested_outfits
    @project_id = ENV['GOOGLE_CLOUD_PROJECT']
    @location = ENV['GOOGLE_CLOUD_LOCATION'] || 'us-central1'
    @api_endpoint = "https://#{@location}-aiplatform.googleapis.com/v1/projects/#{@project_id}/locations/#{@location}/publishers/google/models/gemini-2.5-flash:generateContent"
  end

  def detect_missing_items
    Rails.logger.info("MissingItemDetector: Starting detection for user ##{@user.id}")

    # Build comprehensive prompt
    user_prompt = build_detection_prompt
    Rails.logger.info("MissingItemDetector: Built prompt (#{user_prompt.length} chars)")

    # Call Gemini API
    response = call_gemini_api(user_prompt)
    Rails.logger.info("MissingItemDetector: Received response from Gemini API")

    # Parse and validate response
    result = parse_and_validate_response(response)
    Rails.logger.info("MissingItemDetector: Parsed #{result.size} missing items")

    if result.empty?
      Rails.logger.warn("MissingItemDetector: AI returned empty array - wardrobe may be complete")
      Rails.logger.warn("MissingItemDetector: Raw response preview: #{response.inspect[0..500]}")
    end

    result
  rescue StandardError => e
    Rails.logger.error("MissingItemDetector: Detection failed with #{e.class.name}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    # Return empty array on failure to prevent blocking user experience
    []
  end

  private

  def call_gemini_api(user_prompt)
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    authorizer = Google::Auth.get_application_default(scopes)
    token = authorizer.fetch_access_token!['access_token']

    full_prompt = "#{SYSTEM_PROMPT}\n\n#{user_prompt}"

    body = {
      contents: [
        {
          role: 'user',
          parts: [{ text: full_prompt }]
        }
      ],
      generationConfig: {
        temperature: 0.6,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 4096,
        responseMimeType: 'application/json'
      }
    }

    response = HTTParty.post(
      @api_endpoint,
      headers: {
        'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/json'
      },
      body: body.to_json,
      timeout: 60
    )

    unless response.success?
      Rails.logger.error("Gemini API Error (Missing Item Detection): #{response.code} - #{response.body}")
      raise DetectionError, "AI service unavailable (#{response.code})"
    end

    extract_json_from_response(response.parsed_response)
  rescue HTTParty::Error, Net::OpenTimeout => e
    Rails.logger.error("Network error calling Gemini for missing item detection: #{e.message}")
    raise DetectionError, "Network error: #{e.message}"
  end

  def extract_json_from_response(response_body)
    candidates = response_body['candidates']
    raise DetectionError, 'No candidates returned from AI' if candidates.nil? || candidates.empty?

    candidate = candidates.first
    raw_text = candidate.dig('content', 'parts', 0, 'text')
    raise DetectionError, 'Could not extract text from AI response' if raw_text.nil?

    # Clean markdown formatting if present
    cleaned_text = raw_text.gsub(/```json\n?/, '').gsub(/```/, '').strip

    JSON.parse(cleaned_text)
  rescue JSON::ParserError
    Rails.logger.error("Failed to parse JSON from AI. Raw text (first 500 chars): #{raw_text[0..500]}")
    raise DetectionError, 'AI returned an invalid response format'
  end

  def build_detection_prompt
    user_profile_text = build_user_profile_section
    wardrobe_summary = build_wardrobe_summary
    outfit_context_text = build_outfit_context_section

    <<~PROMPT
      OUTFIT CONTEXT: #{@outfit_context}

      #{user_profile_text}

      #{wardrobe_summary}

      #{outfit_context_text}

      TASK: Analyze the wardrobe gaps and suggest 1-3 missing items that would:
      1. Complete or enhance the outfits for the given context
      2. Fill critical gaps in the wardrobe categories
      3. Align with the user's style preference and presentation style
      4. Maximize versatility with existing wardrobe items

      Prioritize items by their impact on wardrobe completeness and versatility.

      Return JSON only. No markdown.
    PROMPT
  end

  def build_user_profile_section
    return '' unless @user.user_profile.present?

    profile = @user.user_profile
    text = 'USER PROFILE:'
    text += "\n- Presentation style: #{profile.presentation_style&.humanize}" if profile.presentation_style.present?
    text += "\n- Style preference: #{profile.style_preference&.humanize}" if profile.style_preference.present?
    text += "\n- Body type: #{profile.body_type&.humanize}" if profile.body_type.present?
    text += "\n- Age range: #{profile.age_range}" if profile.age_range.present?
    text += "\n- Favorite colors: #{profile.favorite_colors.join(', ')}" if profile.favorite_colors.any?
    text += "\n\nConsider these preferences when suggesting missing items. Prioritize colors from their favorites and match formality to their style preference."
    text
  end

  def build_wardrobe_summary
    wardrobe_items = @user.wardrobe_items.includes(:image_attachment)

    # Group by category
    category_counts = wardrobe_items.group_by { |item| normalize_category(item.category) }
                                    .transform_values(&:count)
                                    .sort_by { |_category, count| -count }
                                    .to_h

    # Get color distribution
    color_counts = wardrobe_items.group_by(&:color)
                                 .transform_values(&:count)
                                 .sort_by { |_color, count| -count }
                                 .first(5)
                                 .to_h

    text = "CURRENT WARDROBE SUMMARY (#{wardrobe_items.count} items):\n"
    text += "\nCategories:\n"
    category_counts.each do |category, count|
      text += "- #{category || 'unknown'}: #{count} items\n"
    end

    text += "\nDominant Colors:\n"
    color_counts.each do |color, count|
      text += "- #{color || 'unknown'}: #{count} items\n"
    end

    # Identify obvious gaps
    text += "\n#{identify_category_gaps(category_counts)}"

    text
  end

  def normalize_category(category)
    return 'unknown' if category.blank?

    cat = category.downcase

    # Group similar categories
    if cat.include?('shirt') || cat.include?('blouse') || cat.include?('top')
      'tops/shirts'
    elsif cat.include?('pant') || cat.include?('jean') || cat.include?('trouser')
      'pants/jeans'
    elsif cat.include?('shoe') || cat.include?('sneaker') || cat.include?('boot')
      'shoes'
    elsif cat.include?('jacket') || cat.include?('coat') || cat.include?('blazer')
      'outerwear'
    elsif cat.include?('dress')
      'dresses'
    elsif cat.include?('skirt')
      'skirts'
    elsif cat.include?('short')
      'shorts'
    elsif cat.include?('sweater') || cat.include?('cardigan')
      'sweaters'
    elsif cat.include?('accessory') || cat.include?('belt') || cat.include?('tie')
      'accessories'
    else
      category
    end
  end

  def identify_category_gaps(category_counts)
    essential_categories = {
      'tops/shirts' => 5,
      'pants/jeans' => 3,
      'shoes' => 3,
      'outerwear' => 2
    }

    gaps = []
    essential_categories.each do |category, min_count|
      current_count = category_counts[category] || 0
      if current_count < min_count
        gaps << "- Missing sufficient #{category} (have #{current_count}, recommend at least #{min_count})"
      end
    end

    if gaps.any?
      "IDENTIFIED GAPS:\n#{gaps.join("\n")}"
    else
      'IDENTIFIED GAPS: None - wardrobe has good coverage of essential categories'
    end
  end

  def build_outfit_context_section
    return '' if @suggested_outfits.blank?

    text = "SUGGESTED OUTFITS FOR THIS CONTEXT:\n"

    @suggested_outfits.first(3).each_with_index do |outfit, index|
      items = outfit[:items] || []
      categories = items.map { |item| item[:category] || item['category'] || 'unknown' }.join(', ')
      reasoning = outfit[:reasoning] || 'No reasoning provided'

      text += "\nOutfit #{index + 1} (confidence: #{outfit[:confidence] || 0}):\n"
      text += "- Items: #{categories}\n"
      text += "- Reasoning: #{reasoning}\n"
    end

    text += "\nConsider what items, if added to the wardrobe, would create better outfit options for this context."
    text
  end

  def parse_and_validate_response(response)
    missing_items_data = response['missing_items']

    # Return empty array if no suggestions
    return [] unless missing_items_data.is_a?(Array)
    return [] if missing_items_data.empty?

    # Validate and clean each suggestion
    valid_items = missing_items_data.map do |item_data|
      # Validate required fields
      next unless item_data['category'].present?
      next unless item_data['description'].present?

      # Build validated item hash
      {
        category: item_data['category'],
        description: item_data['description'],
        color_preference: item_data['color_preference'] || 'neutral',
        style_notes: item_data['style_notes'] || '',
        reasoning: item_data['reasoning'] || 'Would enhance wardrobe versatility',
        priority: validate_priority(item_data['priority']),
        budget_range: item_data['budget_range'] || '$50-100'
      }
    end.compact

    # Sort by priority (high > medium > low)
    valid_items.sort_by do |item|
      case item[:priority]
      when 'high' then 0
      when 'medium' then 1
      when 'low' then 2
      else 3
      end
    end
  end

  def validate_priority(priority)
    valid_priorities = %w[high medium low]
    return 'medium' unless priority.is_a?(String)

    normalized = priority.downcase.strip
    valid_priorities.include?(normalized) ? normalized : 'medium'
  end
end
