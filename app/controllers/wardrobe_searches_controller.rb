class WardrobeSearchesController < ApplicationController
  before_action :authenticate_user!

  # GET /wardrobe_searches/new - Search form
  def new
    @can_search_images = current_user.can_search_images?
    @remaining_searches = current_user.remaining_image_searches_today
    @is_premium = current_user.premium?
  end

  # POST /wardrobe_searches - Perform search
  def create
    @search_service = WardrobeSearchService.new(current_user)

    if params[:image].present?
      perform_image_search
    elsif params[:query].present?
      perform_text_search
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "search-results",
            partial: "wardrobe_searches/error",
            locals: { message: "Please provide an image or search query." }
          )
        end
        format.html { redirect_to new_wardrobe_search_path, alert: "Please provide an image or search query." }
      end
    end
  end

  private

  def perform_image_search
    result = @search_service.search_by_image(params[:image], limit: 12)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "search-results",
            partial: "wardrobe_searches/results",
            locals: { results: result[:items], metadata: result[:metadata], search_type: "image" }
          ),
          turbo_stream.replace(
            "remaining-searches",
            partial: "wardrobe_searches/remaining_searches",
            locals: { remaining: result[:metadata][:remaining_searches] }
          )
        ]
      end
      format.html { redirect_to new_wardrobe_search_path }
    end
  rescue WardrobeSearchService::SearchError => e
    handle_search_error(e)
  end

  def perform_text_search
    result = @search_service.search_by_text(params[:query], limit: 12)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "search-results",
          partial: "wardrobe_searches/results",
          locals: { results: result[:items], metadata: result[:metadata], search_type: "text" }
        )
      end
      format.html { redirect_to new_wardrobe_search_path }
    end
  rescue WardrobeSearchService::SearchError => e
    handle_search_error(e)
  end

  def handle_search_error(error)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "search-results",
          partial: "wardrobe_searches/error",
          locals: { message: error.message }
        )
      end
      format.html { redirect_to new_wardrobe_search_path, alert: error.message }
    end
  end
end
