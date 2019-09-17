require 'rails_helper'

describe 'Admin clicks My Order on user profile' do
  it 'Show index of that users orders' do
    tire = create(:item, price: 100)
    paper = create(:item, price: 20)
    pencil = create(:item, price: 2)
    user = create(:user)
    order_1 = create(:order, user: user)
    order_2 = create(:order, user: user)
    orders = [order_1,order_2]
    item_order_1 = order_1.item_orders.create!(item: tire, price: tire.price, quantity: 2)
    item_order_2 = order_2.item_orders.create!(item: paper, price: paper.price, quantity: 4)
    item_order_3 = order_2.item_orders.create!(item: pencil, price: pencil.price, quantity: 6)
    admin = create(:user, role: 4)

    visit '/login'

    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password

    within '#login-form' do
      click_on 'Log In'
    end

    within '.topnav' do
      click_link 'Users'
    end

    click_link user.name

    click_link 'User Orders'

    expect(current_path).to eq("/admin/users/#{user.id}/orders")

    expect(page).to have_css("#order-#{order_1.id}")
    expect(page).to have_css("#order-#{order_2.id}")

    click_link "Order ##{order_1.id}"

    expect(current_path).to eq("/admin/users/#{user.id}/orders/#{order_1.id}")
  end
end
