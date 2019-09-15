require 'rails_helper'

describe 'User clicks link to add a new address from their profile' do
  it 'Takes them to a form to create a new address' do
    user = create(:user)

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    click_link 'New Address'
    expect(current_path).to eq(user_address_new_path(user))

    fill_in 'Address nickname', with: 'Home'
    fill_in 'Name', with: 'Curly'
    fill_in 'Address', with: '2345 My Street'
    fill_in 'City', with: 'Cool City'
    fill_in 'State', with: 'CO'
    fill_in 'Zip', with: '80303'

    click_on 'Create Address'

    expect(current_path).to eq("/profile")

    address = user.addresses.last

    within "#address-#{address.id}" do
      expect(page).to have_content(address.nickname)
      expect(page).to have_content(address.name)
      expect(page).to have_content(address.address)
      expect(page).to have_content(address.city)
      expect(page).to have_content(address.state)
      expect(page).to have_content(address.zip)
      expect(page).to have_link('Edit Address')
      expect(page).to have_link('Delete Address')
    end
  end
end
