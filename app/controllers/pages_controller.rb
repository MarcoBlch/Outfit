class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @recent_items = current_user.wardrobe_items.order(created_at: :desc).limit(4)
    @recent_outfits = current_user.outfits.order(created_at: :desc).limit(3)
    
    # Simple "Outfit of the Day" logic (random for now)
    @outfit_of_the_day = current_user.outfits.order("RANDOM()").first
  end
end
