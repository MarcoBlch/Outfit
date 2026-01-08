class UpdateMarcoUsername < ActiveRecord::Migration[7.1]
  def up
    # Update bernardmarc92@gmail.com user's username to "marco"
    User.reset_column_information
    user = User.find_by(email: 'bernardmarc92@gmail.com')
    if user
      user.update_column(:username, 'marco')
      puts "Updated user #{user.email} username to 'marco'"
    end
  end

  def down
    # No need to revert this change
  end
end
