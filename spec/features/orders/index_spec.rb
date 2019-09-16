require 'rails_helper'

describe 'User order index page' do
  before :each do

    @tire = create(:item, price: 100)
    @paper = create(:item, price: 20)
    @pencil = create(:item, price: 2)
    @user = create(:user)
    @order_1 = create(:order, user: @user)
    @order_2 = create(:order, user: @user)
    @orders = [@order_1,@order_2]
    @item_order_1 = @order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
    @item_order_2 = @order_2.item_orders.create!(item: @paper, price: @paper.price, quantity: 4)
    @item_order_3 = @order_2.item_orders.create!(item: @pencil, price: @pencil.price, quantity: 6)

    visit '/login'

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password

    within '#login-form' do
      click_on 'Log In'
    end
  end
  it "shows all user orders" do
    visit '/profile/orders'

    @orders.each do |order|
      within "#order-#{order.id}" do
        expect(page).to have_link(order.id)
        expect(page).to have_content(order.created_at.strftime('%D'))
        expect(page).to have_content(order.updated_at.strftime('%D'))
        expect(page).to have_content(order.status)
        expect(page).to have_content(order.items_count)
        expect(page).to have_content("$#{order.grandtotal}")
      end
    end
  end
end
