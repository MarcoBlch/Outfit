class WardrobeItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wardrobe_item, only: %i[show update destroy]

  def index
    @wardrobe_items = current_user.wardrobe_items.order(created_at: :desc)
    
    # Filtering
    @wardrobe_items = @wardrobe_items.where(category: params[:category]) if params[:category].present?
    @wardrobe_items = @wardrobe_items.where(color: params[:color]) if params[:color].present?

    respond_to do |format|
      format.html
      format.json { render json: @wardrobe_items }
    end
  end

  def new
    @wardrobe_item = WardrobeItem.new
  end

  def show
    render json: @wardrobe_item
  end

  def create
    @wardrobe_item = current_user.wardrobe_items.build(wardrobe_item_params)

    if @wardrobe_item.save
      ImageAnalysisJob.perform_later(@wardrobe_item.id)

      respond_to do |format|
        format.html { redirect_to wardrobe_items_path, notice: "Item uploaded! AI analysis in progress..." }
        format.json { render json: @wardrobe_item, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @wardrobe_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @wardrobe_item.update(wardrobe_item_params)
      render json: @wardrobe_item
    else
      render json: @wardrobe_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @wardrobe_item.destroy
  end

  def search
    query = params[:query]
    return render json: { error: "Query parameter is required" }, status: :bad_request if query.blank?

    begin
      embedding = EmbeddingService.new.embed(query)
      # Find nearest neighbors using pgvector
      # We use the 'embedding' column on WardrobeItem
      @wardrobe_items = current_user.wardrobe_items.nearest_neighbors(embedding, distance: :cosine).first(10)
      
      render json: @wardrobe_items
    rescue EmbeddingService::EmbeddingError => e
      render json: { error: e.message }, status: :service_unavailable
    end
  end

  private

  def set_wardrobe_item
    @wardrobe_item = current_user.wardrobe_items.find(params[:id])
  end

  def wardrobe_item_params
    params.require(:wardrobe_item).permit(:category, :color, :image, metadata: {})
  end
end
