require 'rails_helper'

describe 'User clicks Change Address from pending order show page' do
  it 'Takes them to a form to edit the shipping details'do
    user = create(:user)
    address = create(:address)
    user.addresses << address
    item = create(:item)
    order = user.orders.create(name: user.name, address: address.address, city: address.city, state: address.state, zip: address.zip)
    item_order = order.item_orders.create(item: item, price: item.price, quantity: 1)

    visit '/login'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit order_path(order.id)

    click_link 'Edit Shipping Details'

    expect(current_path).to eq(edit_order_path(order))
    fill_in 'Address', with: '123 Updated Address'
    fill_in 'City', with: 'Edit City'
    select 'Hawaii', from: 'State'
    fill_in 'Zip', with: '99999'

    click_on 'Update Order'

    expect(current_path).to eq(order_path(order.id))

    within '.shipping-address' do
      expect(page).to have_content('123 Updated Address')
      expect(page).to have_content('Edit City, HI 99999')
    end
  end
end
