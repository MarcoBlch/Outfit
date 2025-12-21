class AddPresentationStyleToUserProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :user_profiles, :presentation_style, :string
  end
end
