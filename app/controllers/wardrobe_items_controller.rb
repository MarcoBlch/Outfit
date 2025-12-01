class WardrobeItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wardrobe_item, only: %i[show update destroy]

  def index
    @wardrobe_items = current_user.wardrobe_items
    render json: @wardrobe_items
  end

  def show
    render json: @wardrobe_item
  end

  def create
    @wardrobe_item = current_user.wardrobe_items.build(wardrobe_item_params)

    if @wardrobe_item.save
      render json: @wardrobe_item, status: :created
    else
      render json: @wardrobe_item.errors, status: :unprocessable_entity
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

  private

  def set_wardrobe_item
    @wardrobe_item = current_user.wardrobe_items.find(params[:id])
  end

  def wardrobe_item_params
    params.require(:wardrobe_item).permit(:category, :color, :image, metadata: {})
  end
end
