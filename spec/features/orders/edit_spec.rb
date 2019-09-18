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

  it 'User cannot manually visit edit path if order does not belong to them, unless they are admin' do
    @user_2 = create(:user)
    @address_2 = create(:address)
    @user_2.addresses << @address_2
    @item_2 = create(:item)
    @order_2 = @user_2.orders.create(name: @user_2.name, address: @address_2.address, city: @address_2.city, state: @address_2.state, zip: @address_2.zip)
    @item_order_2 = @order_2.item_orders.create(item: @item_2, price: @item_2.price, quantity: 1)

    visit edit_order_path(@order_2)

    expect(page).to have_content("Error 403: Forbidden")

    click_link 'Log Out'

    admin = create(:user, role: 4)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: admin.password
      click_on 'Log In'
    end

    visit edit_order_path(@order)

    expect(page).to_not have_content("Error 403: Forbidden")
    expect(page).to have_button('Update Order')

    visit edit_order_path(@order_2)

    expect(page).to_not have_content("Error 403: Forbidden")
    expect(page).to have_button('Update Order')
  end
end
