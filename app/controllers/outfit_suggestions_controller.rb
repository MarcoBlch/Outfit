class OutfitSuggestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_rate_limit, only: [:create]

  def index
    @suggestions = current_user.outfit_suggestions.recent.limit(20)
  end

  def new
    # Modal view - loaded via Turbo Frame
    render layout: false
  end

  def create
    context = params[:context]

    if context.blank?
      return render turbo_stream: turbo_stream.replace(
        "suggestions-error",
        partial: "outfit_suggestions/error",
        locals: { message: "Please describe an occasion or context" }
      ), status: :unprocessable_entity
    end

    # Create suggestion record
    @suggestion = current_user.outfit_suggestions.create!(
      context: context,
      status: 'pending'
    )

    begin
      # Track start time for performance monitoring
      start_time = Time.current

      # Fetch weather if enabled and available
      weather = nil
      include_weather = params[:include_weather] != "false" # Default to true
      if include_weather && current_user.weather_available?
        weather = current_user.current_weather
      end

      # Call the AI service
      service = OutfitSuggestionService.new(current_user, context, weather: weather)
      outfits = service.generate_suggestions(count: 3)

      # Calculate response time
      response_time_ms = ((Time.current - start_time) * 1000).to_i

      # Mark suggestion as completed with results
      @suggestion.mark_completed!(outfits, response_time_ms, 0.01)

      # Trigger product recommendation workflow (non-blocking)
      trigger_product_recommendations(@suggestion, outfits)

      # Respond with Turbo Stream to update the UI
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "suggestions-results",
              partial: "outfit_suggestions/results",
              locals: { suggestion: @suggestion, outfits: outfits, weather: weather }
            ),
            turbo_stream.update(
              "remaining-count",
              html: current_user.remaining_suggestions_today.to_s
            )
          ]
        end
      end

    rescue OutfitSuggestionService::SuggestionError => e
      @suggestion.mark_failed!(e.message)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "suggestions-error",
            partial: "outfit_suggestions/error",
            locals: { message: e.message }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @suggestion = current_user.outfit_suggestions.find(params[:id])
  end

  def show_recommendations
    @suggestion = current_user.outfit_suggestions.find(params[:id])
    @recommendations = @suggestion.product_recommendations
                                  .includes(:outfit_suggestion)
                                  .order(priority: :desc, created_at: :desc)
  end

  def record_view
    @suggestion = current_user.outfit_suggestions.find(params[:id])
    @recommendation = @suggestion.product_recommendations.find(params[:recommendation_id])

    @recommendation.record_view!

    head :ok
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def record_click
    @suggestion = current_user.outfit_suggestions.find(params[:id])
    @recommendation = @suggestion.product_recommendations.find(params[:recommendation_id])

    @recommendation.record_click!

    # Return the affiliate URL if available
    if @recommendation.affiliate_products.present? && @recommendation.affiliate_products.first['url'].present?
      render json: { url: @recommendation.affiliate_products.first['url'] }, status: :ok
    else
      head :ok
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def check_rate_limit
    unless current_user.can_request_suggestion?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "suggestions-results",
            partial: "outfit_suggestions/rate_limit_reached"
          ), status: :too_many_requests
        end
      end
    end
  end

  def trigger_product_recommendations(suggestion, outfits)
    # Run in a separate thread to avoid blocking the response
    # Wrapped in rescue to ensure outfit suggestion creation always succeeds
    begin
      # Detect missing items using the MissingItemDetector service
      detector = MissingItemDetector.new(
        current_user,
        outfit_context: suggestion.context,
        suggested_outfits: outfits
      )

      missing_items = detector.detect_missing_items

      # Create ProductRecommendation records for each missing item
      missing_items.each do |item_data|
        recommendation = suggestion.product_recommendations.create!(
          category: item_data[:category],
          description: item_data[:description],
          color_preference: item_data[:color_preference],
          style_notes: item_data[:style_notes],
          reasoning: item_data[:reasoning],
          priority: map_priority_to_enum(item_data[:priority]),
          budget_range: map_budget_range(item_data[:budget_range]),
          ai_image_status: :pending,
          affiliate_products: []
        )

        # Enqueue background jobs for image generation and product fetching
        GenerateProductImageJob.perform_later(recommendation.id)
        FetchAffiliateProductsJob.perform_later(recommendation.id)

        Rails.logger.info("Created ProductRecommendation ##{recommendation.id} for OutfitSuggestion ##{suggestion.id}")
      end

      Rails.logger.info("Successfully triggered product recommendations for OutfitSuggestion ##{suggestion.id}: #{missing_items.size} items")
    rescue StandardError => e
      # Log the error but don't raise it - we don't want to break the outfit suggestion flow
      Rails.logger.error("Failed to trigger product recommendations for OutfitSuggestion ##{suggestion.id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end

  def map_priority_to_enum(priority_string)
    case priority_string.to_s.downcase
    when 'high'
      :high
    when 'low'
      :low
    else
      :medium
    end
  end

  def map_budget_range(budget_string)
    # Parse budget string like "$60-120" to determine range
    # Default to mid_range if parsing fails
    return :mid_range if budget_string.blank?

    # Extract max value from range like "$60-120"
    max_value = budget_string.scan(/\d+/).map(&:to_i).max || 100

    case max_value
    when 0..50
      :budget
    when 51..150
      :mid_range
    when 151..300
      :premium
    else
      :luxury
    end
  end
end
