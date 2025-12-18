class AddAdminAnalyticsIndexesToProductRecommendations < ActiveRecord::Migration[7.1]
  def change
    # Add index for priority filtering (already exists, but ensuring it's there)
    # add_index :product_recommendations, :priority unless index_exists?(:product_recommendations, :priority)

    # Add index for revenue-based filtering and sorting
    add_index :product_recommendations, :revenue_earned,
              name: 'index_product_recommendations_on_revenue'

    # Add index for created_at filtering and sorting (for date ranges)
    add_index :product_recommendations, :created_at,
              name: 'index_product_recommendations_on_created_at'

    # Add composite index for high-performing recommendations
    # (views > 0 and high CTR calculations)
    add_index :product_recommendations, [:views, :clicks],
              where: 'views > 0',
              name: 'index_product_recommendations_on_views_and_clicks'

    # Add index for outfit_suggestion_id for filtering by outfit
    # (already exists as part of foreign key, but ensuring it's optimized)
    # add_index :product_recommendations, :outfit_suggestion_id
  end
end
