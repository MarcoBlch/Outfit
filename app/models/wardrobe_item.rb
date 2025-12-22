class WardrobeItem < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :image
  has_one_attached :cleaned_image

  has_neighbors :embedding

  # validates :category, presence: true
  validates :image, presence: true

  # Broadcast updates to home page when item is created or updated
  after_create_commit :broadcast_to_recent_items
  after_update_commit :broadcast_to_recent_items
  after_destroy_commit :broadcast_to_recent_items

  # Helper methods for metadata access
  def tags
    metadata&.dig('tags') || []
  end

  def description
    metadata&.dig('description')
  end

  def image_url
    image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) : nil
  end

  private

  def broadcast_to_recent_items
    # Broadcast replacement of the recent-items turbo-frame
    broadcast_replace_later_to(
      "user_#{user_id}_recent_items",
      target: "recent-items",
      partial: "pages/recent_items",
      locals: { recent_items: user.wardrobe_items.with_attached_image.order(created_at: :desc).limit(4) }
    )
  end
end
