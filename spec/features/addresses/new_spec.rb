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
    select 'Colorado', from: 'State'
    fill_in 'Zip', with: '80303'

    click_on 'Create Address'

    expect(current_path).to eq("/profile")

    address = user.addresses.last

    expect(page).to have_link('New Address')

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

  it 'Users can have multiple addresses' do
    user = create(:user)
    first = create(:address)
    user.addresses << first

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    expect(user.addresses.length).to eq(1)

    click_link 'New Address'

    fill_in 'Address nickname', with: 'Home'
    fill_in 'Name', with: 'Curly'
    fill_in 'Address', with: '2345 My Street'
    fill_in 'City', with: 'Cool City'
    select 'Colorado', from: 'State'
    fill_in 'Zip', with: '80303'

    click_on 'Create Address'

    new = Address.last

    expect(new.id).to_not eq(first.id)
    expect(page).to have_css("#address-#{first.id}")
    expect(page).to have_css("#address-#{new.id}")
  end

  it 'Users must complete the entire new address form' do
    user = create(:user)

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    click_link 'New Address'
    click_on 'Create Address'

    expect(page).to have_content('Add a New Address')
    expect(page).to have_content("Nickname can't be blank, Name can't be blank, Address can't be blank, City can't be blank, State can't be blank, and Zip can't be blank")
  end
end
