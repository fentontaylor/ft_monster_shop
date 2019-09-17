require 'rails_helper'

describe 'User clicks Edit Address link from their profile' do
  it 'Takes them to a pre-filled form to edit their addresses' do
    user = create(:user)
    address = create(:address)
    user.addresses << address

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    within "#address-#{address.id}" do
      click_link 'Edit Address'
    end

    expect(current_path).to eq(user_address_edit_path(user, address))

    fill_in 'Address nickname', with: 'Home'
    fill_in 'Name', with: 'Curly'
    fill_in 'Address', with: '2345 My Street'
    fill_in 'City', with: 'Cool City'
    select 'Colorado', from: 'State'
    fill_in 'Zip', with: '80303'

    click_on 'Update Address'

    expect(current_path).to eq('/profile')

    within "#address-#{address.id}" do
      expect(page).to_not have_content(address.address)
      expect(page).to_not have_content(address.city)
      expect(page).to have_content('Home')
      expect(page).to have_content('Curly')
      expect(page).to have_content('2345 My Street')
      expect(page).to have_content('Cool City, CO 80303')
    end
  end

  it 'User cant leave any part of edit form blank' do
    user = create(:user)
    address = create(:address)
    user.addresses << address

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    within "#address-#{address.id}" do
      click_link 'Edit Address'
    end

    fill_in 'Address nickname', with: nil
    fill_in 'Name', with: nil
    fill_in 'Address', with: nil
    fill_in 'City', with: nil
    select '', from: 'State'
    fill_in 'Zip', with: nil

    click_on 'Update Address'

    expect(page).to have_content("Nickname can't be blank, Name can't be blank, Address can't be blank, City can't be blank, State can't be blank, and Zip can't be blank")
    expect(page).to have_content('Edit This Address')
  end
end

describe 'User can edit address from new order page' do
  it 'Redirects them to the neworder page' do
    user = create(:user)
    user.addresses << create(:address)
    address = user.addresses.first
    merchant = create(:merchant)
    merchant.items << create(:item)
    item = merchant.items.first

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit item_path(item)
    click_link 'Add To Cart'

    visit '/cart'
    click_link 'Checkout'

    within ".address-select" do
      click_on address.nickname
    end
    
    click_link 'Edit Address'

    fill_in 'Address', with: '2345 My Street'
    fill_in 'City', with: 'Cool City'
    select 'California', from: 'State'
    fill_in 'Zip', with: '90505'

    click_on 'Update Address'

    expect(current_path).to eq('/orders/new')

    within ".address-select" do
      click_on address.nickname
    end

    expect(page).to have_content(address.name)
    expect(page).to have_content('2345 My Street')
    expect(page).to have_content('Cool City, CA 90505')
  end
end
