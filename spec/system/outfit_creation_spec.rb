require 'rails_helper'

RSpec.describe 'Outfit Creation', type: :system do
  let(:user) { create(:user) }
  let!(:top) { create(:wardrobe_item, user: user, category: 'top') }
  let!(:bottom) { create(:wardrobe_item, user: user, category: 'bottom') }
  let!(:shoes) { create(:wardrobe_item, user: user, category: 'shoes') }

  before do
    sign_in user
  end

  describe 'Manual Creation' do
    it 'allows user to create a new outfit' do
      visit new_outfit_path
      
      # Assuming a form where you select items or drag/drop. 
      # Since we don't know exact UI for canvas, we'll check for basic form elements if any,
      # or just checking the page loads for now.
      expect(page).to have_content('New Outfit')
      
      fill_in 'Outfit Name', with: 'Casual Friday'
      click_button 'Save Outfit'
      
      expect(page).to have_content('Outfit created')
    end
  end

  describe 'AI Suggestions' do
    it 'generates suggestions' do
      visit outfit_suggestions_path
      
      # Mocking the service would be ideal in unit tests, 
      # but in system tests we might want to mock the HTTP call or the service itself.
      allow_any_instance_of(OutfitSuggestionService).to receive(:generate_suggestions).and_return([
        {
          "items" => [top, bottom, shoes],
          "reasoning" => 'Great combo',
          "confidence" => 90
        }
      ])

      click_link 'Get New Suggestions' rescue click_link 'Get Your First Suggestions'
      
      # Wait for modal
      expect(page).to have_content("What's the occasion?")
      
      fill_in 'context', with: 'work'
      click_button 'Generate Suggestions'
      
      expect(page).to have_content('Great combo')
    end
  end
end
