require 'rails_helper'

RSpec.describe 'User Profile', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'allows user to update their profile' do
    visit edit_user_profile_path

    # Select a style preference (radio button)
    choose 'style_casual', allow_label_click: true

    # Fill in the location field
    fill_in 'user_profile_location', with: 'New York'

    # Submit the form - button text is "Complete Profile" when creating
    click_button 'Complete Profile'

    # Verify success - wait for redirect/update
    expect(page).to have_content('Profile', wait: 5)
    expect(user.reload.user_profile.location).to eq('New York')
  end
end
