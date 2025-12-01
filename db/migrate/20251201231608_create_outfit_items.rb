class CreateOutfitItems < ActiveRecord::Migration[7.1]
  def change
    create_table :outfit_items do |t|
      t.references :outfit, null: false, foreign_key: true
      t.references :wardrobe_item, null: false, foreign_key: true
      t.float :position_x
      t.float :position_y
      t.float :scale
      t.float :rotation
      t.integer :z_index

      t.timestamps
    end
  end
end
