class CreateOutfits < ActiveRecord::Migration[7.1]
  def change
    create_table :outfits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.jsonb :metadata
      t.datetime :last_worn_at
      t.boolean :favorite

      t.timestamps
    end
  end
end
