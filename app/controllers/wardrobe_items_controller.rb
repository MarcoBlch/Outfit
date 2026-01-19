class WardrobeItemsController < ApplicationController
  # TEMPORARY: Authentication disabled for AI navigation testing
  # before_action :authenticate_user!
  before_action :set_wardrobe_item, only: %i[show update destroy]

  def index
    # Eager load image attachments to avoid N+1 queries
    @wardrobe_items = current_user.wardrobe_items
                                  .with_attached_image
                                  .with_attached_cleaned_image
                                  .order(created_at: :desc)

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
    respond_to do |format|
      format.html
      format.json { render json: @wardrobe_item }
    end
  end

  def create
    @wardrobe_item = current_user.wardrobe_items.build(wardrobe_item_params)

    if @wardrobe_item.save
      ImageAnalysisJob.perform_later(@wardrobe_item.id)

      # Check if this is the 5th item (activation!)
      is_activation = current_user.wardrobe_items.count == 5

      respond_to do |format|
        format.html do
          if is_activation
            flash[:analytics_event] = "Activation"
          end
          redirect_to wardrobe_items_path, notice: "Item uploaded! AI analysis in progress..."
        end
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
    # Process tags if present in metadata
    if params[:wardrobe_item][:metadata] && params[:wardrobe_item][:metadata][:tags].is_a?(String)
      params[:wardrobe_item][:metadata][:tags] = params[:wardrobe_item][:metadata][:tags].split(",").map(&:strip).reject(&:blank?)
    end

    if @wardrobe_item.update(wardrobe_item_params)
      respond_to do |format|
        format.html { redirect_to wardrobe_items_path, notice: "Item updated." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("wardrobe_item_#{@wardrobe_item.id}", partial: "wardrobe_items/wardrobe_item", locals: { wardrobe_item: @wardrobe_item }),
            turbo_stream.replace("modal", template: "wardrobe_items/show"),
            turbo_stream.prepend("flash_messages", partial: "shared/flash_message", locals: { message: "Item updated successfully." })
          ]
        end
        format.json { render json: @wardrobe_item }
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modal", template: "wardrobe_items/show"), status: :unprocessable_entity }
        format.json { render json: @wardrobe_item.errors, status: :unprocessable_entity }
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def destroy
    @wardrobe_item.destroy
    
    respond_to do |format|
      format.html { redirect_to wardrobe_items_path, notice: "Item removed." }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@wardrobe_item),
          turbo_stream.update("modal", ""),
          turbo_stream.prepend("flash_messages", partial: "shared/flash_message", locals: { message: "Item removed.", type: "notice" })
        ]
      end
    end
  end

  def search
    @wardrobe_items = current_user.wardrobe_items
                                  .with_attached_image
                                  .with_attached_cleaned_image

    if params[:query].present?
      @wardrobe_items = @wardrobe_items.where("category ILIKE ? OR color ILIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    render turbo_stream: turbo_stream.update("wardrobe_grid", partial: "wardrobe_items/grid", locals: { wardrobe_items: @wardrobe_items })
  end

  private

  def set_wardrobe_item
    @wardrobe_item = current_user.wardrobe_items.find(params[:id])
  end

  def handle_record_not_found
    respond_to do |format|
      format.html { redirect_to wardrobe_items_path, alert: "Item not found." }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("modal", ""),
          turbo_stream.prepend("flash_messages", partial: "shared/flash_message", locals: { message: "Item already removed.", type: "alert" })
        ]
      end
      format.json { render json: { error: "Item not found" }, status: :not_found }
    end
  end

  def wardrobe_item_params
    params.require(:wardrobe_item).permit(:category, :color, :image, metadata: {})
  end
end
