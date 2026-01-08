class AddMissingColumnsToAdImpressions < ActiveRecord::Migration[7.1]
  def up
    # Add missing columns to ad_impressions table (only if they don't exist)

    # Optional: Track which ad network served the ad
    add_column :ad_impressions, :ad_network, :string, limit: 50 unless column_exists?(:ad_impressions, :ad_network)

    # Optional: Track ad unit ID for detailed analytics
    add_column :ad_impressions, :ad_unit_id, :string, limit: 100 unless column_exists?(:ad_impressions, :ad_unit_id)

    # Optional: User's IP address for fraud detection (anonymized)
    add_column :ad_impressions, :ip_address, :string, limit: 45 unless column_exists?(:ad_impressions, :ip_address)

    # Optional: User agent for device/browser analytics
    add_column :ad_impressions, :user_agent, :string, limit: 500 unless column_exists?(:ad_impressions, :user_agent)

    # Add missing indexes for analytics queries (only if they don't exist)

    # Index for click-through rate (CTR) analysis
    add_index :ad_impressions, :clicked,
              name: "index_ad_impressions_on_clicked" unless index_exists?(:ad_impressions, :clicked, name: "index_ad_impressions_on_clicked")

    # Composite index for placement performance over time
    add_index :ad_impressions, [:placement, :created_at],
              name: "index_ad_impressions_on_placement_and_created_at" unless index_exists?(:ad_impressions, [:placement, :created_at], name: "index_ad_impressions_on_placement_and_created_at")

    # Partial index for clicked ads (much smaller subset)
    add_index :ad_impressions, [:placement, :created_at],
              where: "clicked = true",
              name: "index_ad_impressions_on_placement_and_created_at_clicked" unless index_exists?(:ad_impressions, [:placement, :created_at], name: "index_ad_impressions_on_placement_and_created_at_clicked")

    # Change revenue precision to match migration spec
    change_column :ad_impressions, :revenue, :decimal, precision: 10, scale: 6, default: 0.0

    # Add limit to placement column
    change_column :ad_impressions, :placement, :string, limit: 50, null: false
  end

  def down
    # Remove indexes
    remove_index :ad_impressions, name: "index_ad_impressions_on_placement_and_created_at_clicked"
    remove_index :ad_impressions, name: "index_ad_impressions_on_placement_and_created_at"
    remove_index :ad_impressions, name: "index_ad_impressions_on_clicked"

    # Revert column changes (back to original types)
    change_column :ad_impressions, :placement, :string, limit: nil, null: false
    change_column :ad_impressions, :revenue, :decimal, precision: 10, scale: 4, default: 0.0

    # Remove added columns
    remove_column :ad_impressions, :user_agent
    remove_column :ad_impressions, :ip_address
    remove_column :ad_impressions, :ad_unit_id
    remove_column :ad_impressions, :ad_network
  end
end
