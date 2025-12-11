class AddIndexesForAdminQueries < ActiveRecord::Migration[7.1]
  def change
    # Indexes for admin dashboard analytics queries
    # These optimize common filtering and aggregation patterns

    # Users table indexes for admin filtering
    # Index on subscription_tier for filtering users by tier and MRR calculations
    add_index :users, :subscription_tier, name: "index_users_on_subscription_tier"

    # Index on created_at for cohort analysis and signup trends
    # Most admin queries will order by or filter on created_at
    add_index :users, :created_at, name: "index_users_on_created_at"

    # Composite index for subscription tier analytics over time
    # Optimizes queries like: "Premium users who signed up this month"
    add_index :users, [:subscription_tier, :created_at],
              name: "index_users_on_tier_and_created_at"

    # Outfit suggestions table indexes for usage analytics
    # Index on created_at for time-series analytics (daily/weekly/monthly usage)
    add_index :outfit_suggestions, :created_at,
              name: "index_outfit_suggestions_on_created_at"

    # Index on context for "top contexts" analytics
    # Uses hash index for exact matching (faster than B-tree for text equality)
    add_index :outfit_suggestions, :context,
              using: :hash,
              name: "index_outfit_suggestions_on_context"

    # Outfits table indexes for user engagement metrics
    add_index :outfits, :created_at, name: "index_outfits_on_created_at"

    # Index for favorite outfits analytics
    add_index :outfits, :favorite, where: "favorite = true",
              name: "index_outfits_on_favorite_true"

    # Wardrobe items table indexes for storage/upload analytics
    add_index :wardrobe_items, :created_at,
              name: "index_wardrobe_items_on_created_at"

    # Composite index for per-user wardrobe size queries
    # Optimizes "wardrobe items per user" and "users with >N items"
    add_index :wardrobe_items, [:user_id, :created_at],
              name: "index_wardrobe_items_on_user_and_created_at"
  end
end
