require 'rails_helper'

describe 'User clicks Change Address from pending order show page' do
  before :each do
    @user = create(:user)
    @address = create(:address)
    @user.addresses << @address
    @item = create(:item)
    @order = @user.orders.create(name: @user.name, address: @address.address, city: @address.city, state: @address.state, zip: @address.zip)
    @item_order = @order.item_orders.create(item: @item, price: @item.price, quantity: 1)

    visit '/login'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password

    within '#login-form' do
      click_on 'Log In'
    end
  end

  it 'Takes them to a form to edit the shipping details'do
    visit order_path(@order)

    click_link 'Edit Shipping Details'

    expect(current_path).to eq(edit_order_path(@order))
    fill_in 'Address', with: '123 Updated Address'
    fill_in 'City', with: 'Edit City'
    select 'Hawaii', from: 'State'
    fill_in 'Zip', with: '99999'

    click_on 'Update Order'

    expect(current_path).to eq(order_path(@order))

    within '.shipping-address' do
      expect(page).to have_content('123 Updated Address')
      expect(page).to have_content('Edit City, HI 99999')
    end
  end

  it 'Needs to have all fields filled in' do
    visit edit_order_path(@order)

    fill_in 'Name', with: nil
    fill_in 'Address', with: nil
    fill_in 'City', with: nil
    select '', from: 'State'
    fill_in 'Zip', with: nil

    click_on 'Update Order'

    expect(current_path).to eq(edit_order_path(@order))
    expect(page).to have_content("Name can't be blank, Address can't be blank, City can't be blank, State can't be blank, and Zip can't be blank")
  end

  it 'User cannot manually visit edit path if order is not pending' do
    packaged_order = create(:order, status: 1)
    @user.orders << packaged_order

    visit edit_order_path(packaged_order)

    expect(page).to have_content("The page you were looking for doesn't exist.")
  end
end
