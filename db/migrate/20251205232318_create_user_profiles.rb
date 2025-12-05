class CreateUserProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :style_preference
      t.integer :body_type
      t.string :age_range
      t.string :location
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :user_profiles, :style_preference
    add_index :user_profiles, :body_type
  end
end
