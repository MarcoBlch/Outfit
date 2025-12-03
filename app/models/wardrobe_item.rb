class WardrobeItem < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :image
  
  has_neighbors :embedding

  validates :category, presence: true
  validates :image, presence: true
end
