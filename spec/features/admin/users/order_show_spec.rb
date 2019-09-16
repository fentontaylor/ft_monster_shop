require 'rails_helper'

describe 'admin user order show page' do
  before :each do
    @admin = create(:user, role: 4)
    @user = create(:user)
    @order = create(:order, status: 0, user_id: @user.id)
    @tire = create(:item)
    @paper = create(:item)
    @item_order_1 = @order.item_orders.create!(item: @tire, price: 35, quantity: 2)
    @item_order_2 = @order.item_orders.create!(item: @paper, price: 40, quantity: 4)
    visit login_path

    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: @admin.password

    within '#login-form' do
      click_on 'Log In'
    end
  end

  it 'an admin can click an order id and see an admin only show page' do
    visit '/admin'

    expect(page).to have_link("Order ##{@order.id}")

    click_link "Order ##{@order.id}"

    expect(current_path).to eq("/admin/users/#{@user.id}/orders/#{@order.id}")

    expect(page).to have_content(@order.id)
    expect(page).to have_content(@order.created_at.strftime('%D'))
    expect(page).to have_content(@order.updated_at.strftime('%D'))
    expect(page).to have_content(@order.status)

    within "#item-#{@item_order_1.item_id}" do
      expect(page).to have_link(@item_order_1.item.name)
      expect(page).to have_link(@item_order_1.item.merchant.name)
      expect(page).to have_content("$35.00")
      expect(page).to have_content(@item_order_1.quantity)
      expect(page).to have_content("$70.00")
    end

    within "#item-#{@item_order_2.item_id}" do
      expect(page).to have_link(@item_order_2.item.name)
      expect(page).to have_link(@item_order_2.item.merchant.name)
      expect(page).to have_content("$40.00")
      expect(page).to have_content(@item_order_2.quantity)
      expect(page).to have_content("$160.00")
    end
  end
end
