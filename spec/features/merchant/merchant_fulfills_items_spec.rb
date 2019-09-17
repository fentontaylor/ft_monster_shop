require 'rails_helper'

require 'rails_helper'

describe 'Merchant views order from their dashboard' do
  it 'They can fulfill items' do
    dog_shop = Merchant.create(name: "Sue's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
    stache = dog_shop.items.create(name: "Humunga Stache", description: "Make your dog look like an old-timey gentleman!", price: 19, image: "https://www.glamourmutt.com/thumbnail.asp?file=assets/images/stache1.jpg&maxx=300&maxy=0", inventory: 21)
    pugtato = dog_shop.items.create(name: "Baked Pugtato", description: "Feeds a family of four!", price: 300, image: "https://i.redd.it/l6od6xh0e9jy.jpg", inventory: 2)
    sue = dog_shop.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)

    bob = User.create(name: 'Bob', email: 'bob@email.com', password: 'bob', password_confirmation: 'bob', role: 1)
    address = bob.addresses.create(nickname: 'Home', name: 'Bob', address: '123 A Ave', city: 'Los Angeles', state: 'CA', zip: 90210)
    order = bob.orders.create(name: 'Bob', address: '123 A Ave', city: 'Los Angeles', state: 'CA', zip: 90210)
    order.item_orders.create(item: stache, price: stache.price, quantity: 1)
    order.item_orders.create(item: pugtato, price: pugtato.price, quantity: 1)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: sue.email
      fill_in 'Password', with: sue.password
      click_on 'Log In'
    end

    click_link "Order ##{order.id}"

    within "#merchant-item-order-#{stache.id}" do
      expect(page).to have_link('Fulfill')
      click_link 'Fulfill'
      expect(page).to have_content('Dis item been fulfilled, yo.')
    end

    within "#merchant-item-order-#{pugtato.id}" do
      expect(page).to have_link('Fulfill')
      click_link 'Fulfill'
      expect(page).to have_content('Dis item been fulfilled, yo.')
    end
  end
end
