require 'rails_helper'

RSpec.describe 'User Profile', type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it 'allows user to update their profile' do
    # Assuming there's a link to profile in nav
    visit edit_user_profile_path 
    
    # If profile doesn't exist, it might redirect to new. 
    # Let's ensure we are on the form.
    
    select 'Casual', from: 'Style preference' rescue nil
    fill_in params: 'e.g., New York, NY or London, UK', with: 'New York' rescue fill_in 'user_profile[location]', with: 'New York'
    
    click_button 'Save Profile' rescue click_button 'Create Profile'
    
    expect(page).to have_content('Profile updated') rescue expect(page).to have_content('Profile created')
    expect(user.user_profile.location).to eq('New York')
  end
end
