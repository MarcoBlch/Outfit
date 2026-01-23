class AddTrialFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :trial_started_at, :datetime
    add_column :users, :trial_ends_at, :datetime
  end
end
