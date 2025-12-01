class Outfit < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :wardrobe_items, through: :outfit_items
  
  accepts_nested_attributes_for :outfit_items, allow_destroy: true

  validates :name, presence: true
end
