class CreateWardrobeItems < ActiveRecord::Migration[7.1]
  def change
    create_table :wardrobe_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :color
      t.jsonb :metadata
      t.column :embedding, 'vector(768)'

      t.timestamps
    end
    add_index :wardrobe_items, :embedding, using: :hnsw, opclass: :vector_l2_ops
  end
end
