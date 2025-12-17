class ChangePresentationStyleToIntegerInUserProfiles < ActiveRecord::Migration[7.1]
  def up
    # Remove the string column if it exists
    if column_exists?(:user_profiles, :presentation_style)
      remove_column :user_profiles, :presentation_style
    end
    # Add it back as integer for enum
    add_column :user_profiles, :presentation_style, :integer
  end

  def down
    if column_exists?(:user_profiles, :presentation_style)
      remove_column :user_profiles, :presentation_style
    end
    add_column :user_profiles, :presentation_style, :string
  end
end
