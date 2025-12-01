class WardrobeItem < ApplicationRecord
  belongs_to :user
  has_many :outfit_items, dependent: :destroy
  has_many :outfits, through: :outfit_items
  has_one_attached :image
  
  scope :nearest_neighbors, ->(embedding, distance: "euclidean") {
    operator = case distance
               when "inner_product" then "<#>"
               when "cosine" then "<=>"
               else "<->" # euclidean
               end
    vector_string = embedding.is_a?(Array) ? "[#{embedding.join(',')}]" : embedding
    order(Arel.sql("embedding #{operator} '#{vector_string}'"))
  }

  validates :category, presence: true
  validates :image, presence: true
end
