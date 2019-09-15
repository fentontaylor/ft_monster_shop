require 'rails_helper'

describe "404 if user is not logged in" do
  it "should render 404" do
    visit "/profile"

    expect(page).to have_content("The page you were looking for doesn't exist.")
  end
end

describe 'User visits their profile page' do
  before :each do
    @user = create(:user)

    visit '/login'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password

    within '#login-form' do
      click_on 'Log In'
    end
  end

  it 'Show all their info inlucing edit link' do

    within '.user-profile' do
      expect(current_path).to eq('/profile')

      expect(page).to have_content("#{@user.name}'s Profile")
      expect(page).to have_content("Email: #{@user.email}")

      expect(page).to have_link('Edit Profile')
      expect(page).to have_link('Change Password')

      expect(page).to have_content('My Addresses')
      expect(page).to have_content("You don't have any addresses on file. Would you like to add a")
      expect(page).to have_link('New Address')
    end
  end

  it 'has a link to view past orders' do
    expect(page).to have_link('My Orders')
    click_link('My Orders')
    expect(current_path).to eq("/profile/orders")
  end
end
