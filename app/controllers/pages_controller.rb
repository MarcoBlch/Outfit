class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :terms]

  def home
    # Eager load image attachments to avoid N+1 queries
    @recent_items = current_user.wardrobe_items
                                .with_attached_image
                                .with_attached_cleaned_image
                                .order(created_at: :desc)
                                .limit(4)

    # Eager load wardrobe items and their images for outfits
    # Using preload instead of includes to avoid AVOID warnings when not filtering
    @recent_outfits = current_user.outfits
                                  .preload(wardrobe_items: { image_attachment: :blob, cleaned_image_attachment: :blob })
                                  .order(created_at: :desc)
                                  .limit(3)

    # Simple "Outfit of the Day" logic (random for now) - not currently used in view
    @outfit_of_the_day = current_user.outfits
                                     .order("RANDOM()")
                                     .first
  end

  def privacy
  end

  def terms
  end

  def blog
  end

  def faq
  end

  def help
  end
end
