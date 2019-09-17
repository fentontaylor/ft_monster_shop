require 'rails_helper'

describe 'order ship' do
  it "an order that is shipped will have it's status changed" do
    user = create(:user)
    order = create(:order, user: user, status: 'packaged')
    admin = create(:user, role: 4)

    visit login_path

    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit admin_user_order_path(user, order)

    click_link 'Ship Order'

    expect(page).to have_content("shipped")
    expect(page).to have_content("Order No. #{order.id} has been shipped, yo!")
    expect(current_path).to eq('/admin')
  end
end
