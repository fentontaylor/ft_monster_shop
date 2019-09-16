require 'rails_helper'

describe "New Order Page" do
  describe "When I check out from my cart" do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
    end

    it "I see all the information about my current cart" do
      visit "/cart"

      user = create(:user)
      2.times { user.addresses << create(:address) }
      address = user.addresses.first

      visit '/login'

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password

      within "#login-form" do
        click_on 'Log In'
      end

      visit "/cart"

      click_on "Checkout"

      within "#order-item-#{@tire.id}" do
        expect(page).to have_link(@tire.name)
        expect(page).to have_link("#{@tire.merchant.name}")
        expect(page).to have_content("$#{@tire.price}")
        expect(page).to have_content("1")
        expect(page).to have_content("$100")
      end

      within "#order-item-#{@paper.id}" do
        expect(page).to have_link(@paper.name)
        expect(page).to have_link("#{@paper.merchant.name}")
        expect(page).to have_content("$#{@paper.price}")
        expect(page).to have_content("2")
        expect(page).to have_content("$40")
      end

      within "#order-item-#{@pencil.id}" do
        expect(page).to have_link(@pencil.name)
        expect(page).to have_link("#{@pencil.merchant.name}")
        expect(page).to have_content("$#{@pencil.price}")
        expect(page).to have_content("1")
        expect(page).to have_content("$2")
      end

      expect(page).to have_content("Order Total: $142")
      expect(page).to_not have_link('Create Order')

      within '.address-select' do
        click_on "#{address.nickname}"
      end

      expect(page).to have_content(address.name)
      expect(page).to have_content(address.address)
      expect(page).to have_content("#{address.city}, #{address.state} #{address.zip}")
      
      click_link 'Create Order'

      new_order = Order.last

      expect(current_path).to eq("/profile/orders")

      expect(page).to have_content("Thankz for your business, dawg!")
      expect(page).to have_content(new_order.updated_at.strftime('%D'))
      expect(page).to have_content(new_order.status)
      expect(page).to have_content(new_order.items_count)
      expect(page).to have_content("$142.00")
      expect(page).to have_content(new_order.created_at.strftime('%D'))
    end
  end
end
