require 'rails_helper'

describe 'User clicks Edit Profile link in their profile' do
  it 'Takes them to a prepopulated form to edit their info' do
    user = create(:user)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Log In'
    end

    click_link 'Edit Profile'

    expect(current_path).to eq('/profile/edit')

    click_on 'Update Profile'

    expect(current_path).to eq('/profile')

    click_link 'Edit Profile'

    fill_in 'Name', with: 'Maria'
    fill_in 'Email', with: 'maria@email.com'

    click_on 'Update Profile'

    expect(page).to have_content('Profile updated')

    within '.user-profile' do
      expect(page).to have_content("Maria's Profile")
      expect(page).to have_content("Email: maria@email.com")
    end
  end

  it 'They cant leave any fields blank in edit form' do
    user = create(:user)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Log In'
    end

    click_link 'Edit Profile'

    fill_in 'Name', with: nil
    fill_in 'Email', with: nil

    click_on 'Update Profile'

    expect(current_path).to eq('/profile/edit')
    expect(page).to have_content("Name can't be blank and Email can't be blank")
  end
end
