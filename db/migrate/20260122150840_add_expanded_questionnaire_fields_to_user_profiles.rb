class AddExpandedQuestionnaireFieldsToUserProfiles < ActiveRecord::Migration[7.1]
  def change
    # Add new questionnaire fields for expanded style assessment

    # Multi-select occasions stored as JSONB array
    # Default to empty array to avoid null checks
    add_column :user_profiles, :occasion_focus, :jsonb, default: [], null: false

    # Fit preference enum (0: relaxed, 1: regular, 2: fitted, 3: tailored)
    add_column :user_profiles, :fit_preference, :integer

    # Wardrobe size enum (0: minimal_under_30, 1: small_30_to_75, 2: medium_75_to_150, 3: large_150_plus)
    add_column :user_profiles, :wardrobe_size, :integer

    # Shopping frequency enum (0: rarely, 1: occasionally, 2: regularly, 3: frequently)
    add_column :user_profiles, :shopping_frequency, :integer

    # Primary goal enum (0: organize_existing, 1: get_outfit_ideas, 2: reduce_wardrobe,
    #                     3: build_capsule, 4: track_value, 5: shop_smarter)
    add_column :user_profiles, :primary_goal, :integer

    # Add indexes for columns that will be queried frequently
    # These help with filtering users by these preferences for recommendations and analytics
    add_index :user_profiles, :fit_preference
    add_index :user_profiles, :wardrobe_size
    add_index :user_profiles, :primary_goal

    # GIN index for JSONB column to enable efficient queries on occasion_focus array
    # This allows fast lookups like: WHERE occasion_focus @> '["work"]'::jsonb
    add_index :user_profiles, :occasion_focus, using: :gin
  end
end
