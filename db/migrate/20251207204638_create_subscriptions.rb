class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :stripe_subscription_id, index: { unique: true }
      t.string :stripe_customer_id, index: true
      t.string :stripe_price_id
      t.integer :status, default: 0
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.boolean :cancel_at_period_end, default: false

      t.timestamps
    end
  end
end
