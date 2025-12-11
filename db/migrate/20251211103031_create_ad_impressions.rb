class CreateAdImpressions < ActiveRecord::Migration[7.1]
  def change
    create_table :ad_impressions do |t|
      # Foreign key to user who saw the ad
      t.references :user, null: false, foreign_key: true, index: true

      # Ad placement location (dashboard_banner, wardrobe_grid, outfit_modal, etc.)
      t.string :placement, null: false, limit: 50

      # Whether the ad was clicked
      t.boolean :clicked, default: false, null: false

      # Estimated revenue from this impression (CPM-based calculation)
      # For example: $2 CPM = $0.002 per impression
      t.decimal :revenue, precision: 10, scale: 6, default: 0.0

      # Optional: Track which ad network served the ad
      t.string :ad_network, limit: 50

      # Optional: Track ad unit ID for detailed analytics
      t.string :ad_unit_id, limit: 100

      # Optional: User's IP address for fraud detection (anonymized)
      t.string :ip_address, limit: 45

      # Optional: User agent for device/browser analytics
      t.string :user_agent, limit: 500

      # Timestamps for when the impression occurred
      t.timestamps
    end

    # Indexes for analytics queries

    # Index for revenue calculations by date
    add_index :ad_impressions, :created_at,
              name: "index_ad_impressions_on_created_at"

    # Index for analyzing performance by placement
    add_index :ad_impressions, :placement,
              name: "index_ad_impressions_on_placement"

    # Composite index for per-user impression tracking
    add_index :ad_impressions, [:user_id, :created_at],
              name: "index_ad_impressions_on_user_and_created_at"

    # Index for click-through rate (CTR) analysis
    add_index :ad_impressions, :clicked,
              name: "index_ad_impressions_on_clicked"

    # Composite index for placement performance over time
    add_index :ad_impressions, [:placement, :created_at],
              name: "index_ad_impressions_on_placement_and_created_at"

    # Partial index for clicked ads (much smaller subset)
    add_index :ad_impressions, [:placement, :created_at],
              where: "clicked = true",
              name: "index_ad_impressions_on_placement_and_created_at_clicked"
  end
end
