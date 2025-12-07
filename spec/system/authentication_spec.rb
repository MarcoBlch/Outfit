require 'rails_helper'

RSpec.describe 'Authentication', type: :system do
  describe 'Sign up' do
    it 'allows a new user to sign up' do
      visit new_user_registration_path
      
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'password123'
      fill_in 'Password confirmation', with: 'password123'
      
      click_button 'Sign up'
      
      expect(page).to have_content('Welcome! You have signed up successfully.')
    end
  end

  describe 'Sign in' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123') }

    it 'allows an existing user to sign in' do
      visit new_user_session_path
      
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'password123'
      
      click_button 'Sign in'
      
      expect(page).to have_content('Signed in successfully.')
    end
  end
end
