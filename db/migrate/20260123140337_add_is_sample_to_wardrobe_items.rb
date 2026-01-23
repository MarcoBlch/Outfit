class AddIsSampleToWardrobeItems < ActiveRecord::Migration[7.1]
  def change
    add_column :wardrobe_items, :is_sample, :boolean, default: false
  end
end
