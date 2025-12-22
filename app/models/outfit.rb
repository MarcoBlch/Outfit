class Outfit < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :wardrobe_items, through: :outfit_items

  accepts_nested_attributes_for :outfit_items, allow_destroy: true

  validates :name, presence: true

  # Broadcast updates to home page when outfit is created or updated
  after_create_commit :broadcast_to_recent_outfits
  after_update_commit :broadcast_to_recent_outfits
  after_destroy_commit :broadcast_to_recent_outfits

  private

  def broadcast_to_recent_outfits
    broadcast_refresh_later_to(
      "user_#{user_id}_recent_outfits",
      partial: "pages/recent_outfits",
      locals: { recent_outfits: user.outfits.includes(wardrobe_items: { image_attachment: :blob }).order(created_at: :desc).limit(3) }
    )
  end
end
