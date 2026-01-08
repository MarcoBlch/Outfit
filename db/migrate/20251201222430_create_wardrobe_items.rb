class CreateWardrobeItems < ActiveRecord::Migration[7.1]
  def change
    create_table :wardrobe_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :category
      t.string :color
      t.jsonb :metadata
      # pgvector embedding - only add if extension is available
      # t.column :embedding, 'vector(768)'

      t.timestamps
    end

    # Add vector column and index only if pgvector extension exists
    if pgvector_available?
      add_column :wardrobe_items, :embedding, 'vector(768)'
      add_index :wardrobe_items, :embedding, using: :hnsw, opclass: :vector_l2_ops
    end
  end

  private

  def pgvector_available?
    result = execute("SELECT 1 FROM pg_extension WHERE extname = 'vector'")
    result.any?
  rescue
    false
  end
end
