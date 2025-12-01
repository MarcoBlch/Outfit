class OutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_outfit, only: %i[show update destroy]

  def index
    @outfits = current_user.outfits.includes(:wardrobe_items)
    render json: @outfits, include: :outfit_items
  end

  def show
    render json: @outfit, include: [:outfit_items, :wardrobe_items]
  end

  def create
    @outfit = current_user.outfits.build(outfit_params)

    if @outfit.save
      render json: @outfit, status: :created, include: :outfit_items
    else
      render json: @outfit.errors, status: :unprocessable_entity
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
    params.require(:outfit).permit(
      :name, :favorite, :last_worn_at, metadata: {},
      outfit_items_attributes: [:id, :wardrobe_item_id, :position_x, :position_y, :scale, :rotation, :z_index, :_destroy]
    )
  end
end
