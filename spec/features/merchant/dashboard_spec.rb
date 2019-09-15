require 'rails_helper'

describe 'Merchant employee or admin visits their dashboard' do
  before :each do
    @dog_shop = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
    @pull_toy = @dog_shop.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)
    @dog_bone = @dog_shop.items.create(name: "Dog Bone", description: "They'll love it!", price: 21, image: "https://img.chewy.com/is/image/catalog/54226_MAIN._AC_SL1500_V1534449573_.jpg", active?:false, inventory: 21)

    @user = create(:user)
    @sue = @dog_shop.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)

    @order_1 = @user.orders.create(name: "Evette", address: "123 street", city: "Denver", state: "CO", zip: "12345")
    @io1 = ItemOrder.create(item: @pull_toy, order: @order_1, price: @pull_toy.price, quantity: 5)
    @io2 = ItemOrder.create(item: @dog_bone, order: @order_1, price: @dog_bone.price, quantity: 2)
    @order_2 = @user.orders.create(name: "Evette", address: "123 street", city: "Denver", state: "CO", zip: "12345")
    @io3 = ItemOrder.create(item: @pull_toy, order: @order_2, price: @pull_toy.price, quantity: 1)
    @io4 = ItemOrder.create(item: @dog_bone, order: @order_2, price: @dog_bone.price, quantity: 1)

    visit login_path

    fill_in 'Email', with: @sue.email
    fill_in 'Password', with: @sue.password

    within '#login-form' do
      click_on 'Log In'
    end
  end
  it 'They see company info and pending orders' do

    visit merchant_dash_path

    expect(page).to have_content(@dog_shop.name)
    expect(page).to have_content(@dog_shop.address)
    expect(page).to have_content("#{@dog_shop.city}, #{@dog_shop.state} #{@dog_shop.zip}")

    within "#order-#{@order_1.id}-info" do
      expect(page).to have_link("Order ##{@order_1.id}")
      expect(page).to have_content(@order_1.created_at.strftime('%D'))
      expect(page).to have_content(@order_1.items_count)
      expect(page).to have_content("$92.00")
    end

    within "#order-#{@order_2.id}-info" do
      expect(page).to have_link("Order ##{@order_2.id}")
      expect(page).to have_content(@order_2.created_at.strftime('%D'))
      expect(page).to have_content(@order_2.items_count)
      expect(page).to have_content("$31.00")
    end
  end

  it 'items index' do

    visit '/merchant/items'

    expect(page).to have_content(@dog_shop.name)

    @dog_shop.items.each do |item|
      expect(page).to have_content(item.name)
      expect(page).to have_content(item.inventory)
      expect(page).to have_content(item.price)
    end
  end

  it 'order show' do
    visit merchant_order_show_path(@order_1)

    expect(current_path).to eq("/merchant/orders/#{@order_1.id}")

    expect(page).to have_content("Order ##{@order_1.id}")
    expect(page).to have_content(@order_1.name)
    expect(page).to have_content(@order_1.address)
  end

  it "admin order show is different" do
    admin = create(:user, role: 4)

    click_on 'Log Out'

    visit login_path

    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit merchant_order_show_path(@order_1)

    expect(current_path).to eq("/merchant/orders/#{@order_1.id}")

    expect(page).to have_content("Order ##{@order_1.id}")
    expect(page).to have_content(@order_1.name)
    expect(page).to have_content(@order_1.address)
  end

  it "admin can't access items index through that path" do
    admin = create(:user, role: 4)

    click_on 'Log Out'

    visit login_path

    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit '/merchant'

    expect(page).to have_content("The page you were looking for doesn't exist")
  end

  it "should render items index for admins" do
    admin = create(:user, role: 4)

    click_on 'Log Out'

    visit login_path

    fill_in 'Email', with: admin.email
    fill_in 'Password', with: admin.password

    within '#login-form' do
      click_on 'Log In'
    end

    visit '/merchant/items'

    expect(page).to have_content(@dog_shop.name)

    @dog_shop.items.each do |item|
      expect(page).to have_content(item.name)
      expect(page).to have_content(item.inventory)
      expect(page).to have_content(item.price)
    end
  end
end
