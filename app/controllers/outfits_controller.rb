class OutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_outfit, only: %i[show update destroy]

  def index
    @outfits = current_user.outfits.includes(:wardrobe_items)
    respond_to do |format|
      format.html
      format.json { render json: @outfits, include: :outfit_items }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @outfit, include: [:outfit_items, :wardrobe_items] }
    end
  end

  def new
    @outfit = Outfit.new
    @wardrobe_items = current_user.wardrobe_items.order(created_at: :desc)

    # Pre-select items if passed from AI suggestions
    if params[:wardrobe_item_ids].present?
      @preselected_item_ids = Array(params[:wardrobe_item_ids]).map(&:to_i)
      @preselected_items = current_user.wardrobe_items.where(id: @preselected_item_ids)
    end
  end

  def create
    @outfit = current_user.outfits.build(outfit_params)

    if @outfit.save
      respond_to do |format|
        format.html { redirect_to @outfit, notice: "Outfit created successfully." }
        format.json { render json: @outfit, status: :created, include: :outfit_items }
      end
    else
      @wardrobe_items = current_user.wardrobe_items.order(created_at: :desc)
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @outfit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @outfit.update(outfit_params)
      render json: @outfit, include: :outfit_items
    else
      render json: @outfit.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @outfit.destroy
  end

  private

  def set_outfit
    @outfit = current_user.outfits.find(params[:id])
  end

  def outfit_params
    permitted = params.require(:outfit).permit(
      :name, :favorite, :last_worn_at, metadata: {},
      outfit_items_attributes: [:id, :wardrobe_item_id, :position_x, :position_y, :scale, :rotation, :z_index, :_destroy],
      wardrobe_item_ids: []
    )

    # Handle wardrobe_item_ids by converting to outfit_items_attributes
    if permitted[:wardrobe_item_ids].present? && permitted[:outfit_items_attributes].blank?
      permitted[:outfit_items_attributes] = permitted.delete(:wardrobe_item_ids).map.with_index do |item_id, index|
        { wardrobe_item_id: item_id, z_index: index }
      end
    end

    # Store occasion in metadata if provided
    if params[:outfit][:occasion].present?
      permitted[:metadata] ||= {}
      permitted[:metadata][:occasion] = params[:outfit][:occasion]
    end

    permitted
  end
end
