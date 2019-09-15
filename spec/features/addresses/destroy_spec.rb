require 'rails_helper'

describe 'User clicks Delete Address link in their profile' do
  it 'Destroys the address resource' do
    user = create(:user)
    address = create(:address)
    user.addresses << address

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    expect(page).to have_css("#address-#{address.id}")

    within "#address-#{address.id}" do
      click_link 'Delete Address'
    end

    expect(current_path).to eq ('/profile')
    expect(page).to_not have_css("#address-#{address.id}")
    expect(page).to have_content("#{address.nickname} address has been deleted")
  end
end
