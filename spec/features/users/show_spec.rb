require 'rails_helper'

describe 'User visits their profile page' do
  it 'Show all their info inlucing edit link' do
    user = create(:user)

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    within '.user-profile' do
      expect(current_path).to eq('/profile')

      expect(page).to have_content("#{user.name}'s Profile")
      expect(page).to have_content("#{user.address}")
      expect(page).to have_content("#{user.city}, #{user.state} #{user.zip}")
      expect(page).to have_content("Email: #{user.email}")

      expect(page).to have_link('Edit Profile')
      expect(page).to have_link('Change Password')
      expect(page).to have_link('My Orders')
    end
  end
end
