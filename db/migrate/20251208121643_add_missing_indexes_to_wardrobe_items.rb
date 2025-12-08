class AddMissingIndexesToWardrobeItems < ActiveRecord::Migration[7.1]
  def change
    # CRITICAL: Category is filtered frequently in wardrobe_items_controller.rb:9
    add_index :wardrobe_items, :category,
              comment: 'Improves performance for category filtering'

    # CRITICAL: Color is filtered frequently in wardrobe_items_controller.rb:10
    add_index :wardrobe_items, :color,
              comment: 'Improves performance for color filtering'

    # OPTIMIZATION: Composite index for duplicate prevention and joins
    add_index :outfit_items, [:outfit_id, :wardrobe_item_id],
              name: 'index_outfit_items_on_outfit_and_wardrobe_item',
              comment: 'Prevents duplicate items in outfits, speeds up lookups'

    # ANALYTICS: Subscription tier reporting and filtering
    add_index :users, :subscription_tier,
              comment: 'Improves admin analytics queries'

    # FUTURE FEATURE: Favorite outfits filtering
    add_index :outfits, :favorite,
              where: 'favorite = true',
              comment: 'Partial index for filtering favorite outfits'
  end
end
