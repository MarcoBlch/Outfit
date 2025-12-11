class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add admin flag to users table with secure defaults
    # Default to false for security - admin access must be explicitly granted
    add_column :users, :admin, :boolean, default: false, null: false

    # Partial index: Only index admin=true rows for efficient admin lookups
    # This is much more efficient than indexing all rows since admins are rare
    add_index :users, :admin, where: "admin = true", name: "index_users_on_admin_true"
  end
end
