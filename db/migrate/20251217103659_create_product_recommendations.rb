class CreateProductRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :product_recommendations do |t|
      # Association
      t.references :outfit_suggestion, null: false, foreign_key: true

      # Missing item details from AI analysis
      t.string :category, null: false # e.g., "shoes", "jacket", "accessories"
      t.text :description # AI-generated description of what's missing
      t.string :color_preference # Suggested color to match outfit
      t.text :reasoning # Why this item is recommended
      t.integer :priority, default: 0, null: false # enum: 0=low, 1=medium, 2=high
      t.text :style_notes # Additional styling tips
      t.integer :budget_range, default: 0, null: false # enum: 0=budget, 1=mid_range, 2=premium, 3=luxury

      # AI-generated product image fields
      t.string :ai_image_url # URL to the generated product image
      t.decimal :ai_image_cost, precision: 10, scale: 4, default: 0.0 # Cost for AI image generation
      t.integer :ai_image_status, default: 0, null: false # enum: 0=pending, 1=generating, 2=completed, 3=failed
      t.text :ai_image_error # Error message if image generation fails

      # Affiliate products data stored as JSONB array
      # Structure: [{ title, price, url, image_url, source, rating }]
      t.jsonb :affiliate_products, default: []

      # Analytics fields for tracking performance
      t.integer :views, default: 0, null: false # How many times viewed
      t.integer :clicks, default: 0, null: false # How many clicks on products
      t.integer :conversions, default: 0, null: false # Tracked purchases
      t.decimal :revenue_earned, precision: 10, scale: 2, default: 0.0 # Affiliate revenue

      t.timestamps

      # Indexes for common queries
      t.index [:outfit_suggestion_id, :priority]
      t.index [:outfit_suggestion_id, :created_at]
      t.index :category
      t.index :ai_image_status
      t.index [:clicks, :views] # For CTR calculations
      t.index [:conversions, :clicks] # For conversion rate calculations
    end
  end
end
