class AddUsernameSafelyAndUpdateExisting < ActiveRecord::Migration[7.1]
  def up
    # Add username column if it doesn't exist
    unless column_exists?(:users, :username)
      add_column :users, :username, :string
      add_index :users, :username, unique: true
    end

    # Update existing user with email bernardmarc92@gmail.com
    User.reset_column_information
    user = User.find_by(email: 'bernardmarc92@gmail.com')
    if user && user.username.blank?
      user.update_column(:username, 'marco')
    end

    # Generate usernames for any other users without one
    User.where(username: nil).find_each do |user|
      base_username = user.email.split('@').first.gsub(/[^a-zA-Z0-9_]/, '_')
      base_username = "user_#{base_username}" if base_username.length < 3

      potential_username = base_username
      counter = 1

      while User.exists?(username: potential_username)
        potential_username = "#{base_username}#{counter}"
        counter += 1
      end

      user.update_column(:username, potential_username)
    end
  end

  def down
    remove_index :users, :username if index_exists?(:users, :username)
    remove_column :users, :username if column_exists?(:users, :username)
  end
end
