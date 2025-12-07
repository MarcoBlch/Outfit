require 'rails_helper'

RSpec.describe 'Search Functionality', type: :system do
  let(:user) { create(:user) }
  let!(:red_shirt) { create(:wardrobe_item, user: user, category: 'shirt', color: 'red') }
  let!(:blue_jeans) { create(:wardrobe_item, user: user, category: 'jeans', color: 'blue') }

  before do
    sign_in user
  end

  it 'allows user to search for items by category or color' do
    visit wardrobe_items_path
    
    # Assuming there is a verifyable search input, likely in a sidebar or top bar
    # If standard Rails search:
    # The search input has placeholder "Search items...". 
    # It relies on Turbo/Stimulus to submit on input.
    fill_in 'query', with: 'red' # Name is 'query'
    
    # Wait for Turbo update (Capybara waits for content)
    expect(page).to have_content('Shirt', visible: :all)
    # If we had a non-matching item, we should check it's GONE to verify search works.
    expect(page).not_to have_content('Jeans')
  end
end
