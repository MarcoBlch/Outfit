class CreateOutfitSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :outfit_suggestions do |t|
      t.references :user, null: false, foreign_key: true
      t.text :context, null: false
      t.jsonb :gemini_response
      t.jsonb :validated_suggestions, default: []
      t.integer :suggestions_count, default: 0
      t.decimal :api_cost, precision: 10, scale: 4, default: 0.0
      t.integer :response_time_ms
      t.string :status, default: 'pending' # pending, completed, failed
      t.text :error_message

      t.timestamps

      t.index [:user_id, :created_at]
      t.index :status
    end

    # Add daily usage tracking to users table
    add_column :users, :ai_suggestions_today, :integer, default: 0
    add_column :users, :ai_suggestions_reset_at, :date
    add_column :users, :subscription_tier, :string, default: 'free' # free, premium
  end
end
