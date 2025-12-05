class WardrobeItem < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :image

  has_neighbors :embedding

  # validates :category, presence: true
  validates :image, presence: true

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
end
