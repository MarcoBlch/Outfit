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
end
