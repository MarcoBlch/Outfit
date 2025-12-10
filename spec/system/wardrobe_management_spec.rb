require 'rails_helper'

RSpec.describe 'Wardrobe Management', type: :system do
  let(:user) { create(:user) }
  let!(:image_path) { Rails.root.join('spec', 'fixtures', 'files', 'sample_image.jpg') }

  before do
    sign_in user
  end

  describe 'Adding an item' do
    it 'allows user to upload a new wardrobe item' do
      visit new_wardrobe_item_path

      # The file input is hidden for styling, so we use make_visible to allow Capybara to interact
      attach_file 'wardrobe_item[image]', image_path, make_visible: true
      
      # The form auto-submits on file change or doesn't have standard fields shown immediately.
      # Looking at the view, it seems to rely on auto-submit or valid JS.
      # However, we should try to submit if there is a button. The view says "Submit button is hidden".
      # We better unhide it and click it, or trigger the form submission.
      
      # The form auto-submits on file change, so we need to wait for the submission to complete
      # Try to unhide and click the submit button if it exists, otherwise the form auto-submits
      begin
        page.execute_script("document.querySelector('input[type=\"submit\"]')?.classList.remove('hidden')")
        # Wait a moment for DOM to update
        sleep 0.5
        # Try to click the button if it exists
        if page.has_button?('Upload Item', wait: 1)
          click_button 'Upload Item'
        end
      rescue StandardError
        # If button manipulation fails, form likely auto-submitted
      end

      expect(page).to have_content('Item uploaded', wait: 5)
      # Only the uploaded item should exist
      expect(WardrobeItem.count).to eq(1)
    end
  end

  describe 'Managing items' do
    let!(:item) { create(:wardrobe_item, user: user, category: 'pants', color: 'red') }

    it 'allows user to view and edit an item' do
      visit wardrobe_item_path(item)
      expect(page).to have_content('Pants')

      click_button 'Edit Details'
      
      fill_in 'Color', with: 'Dark Red'
      click_button 'Save Changes'

      expect(page).to have_content('Item updated')
      expect(item.reload.color).to eq('Dark Red')
    end

    it 'allows user to delete an item' do
      visit wardrobe_item_path(item)
      
      accept_confirm do
        click_button 'Delete' # or link
      end

      expect(page).to have_content('Item removed')
      expect(WardrobeItem.count).to eq(0)
    end
  end
end
