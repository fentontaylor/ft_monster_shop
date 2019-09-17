require 'rails_helper'

describe 'Merchant visits their items page' do
  it 'Has link to activate and deactivate items' do
    dog_shop = Merchant.create(name: "Sue's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
    stache = dog_shop.items.create(name: "Humunga Stache", description: "Make your dog look like an old-timey gentleman!", price: 19, image: "https://www.glamourmutt.com/thumbnail.asp?file=assets/images/stache1.jpg&maxx=300&maxy=0", inventory: 21)
    pugtato = dog_shop.items.create(name: "Baked Pugtato", description: "Feeds a family of four!", price: 300, image: "https://i.redd.it/l6od6xh0e9jy.jpg", inventory: 2)
    sue = dog_shop.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: sue.email
      fill_in 'Password', with: sue.password
      click_on 'Log In'
    end

    visit '/merchant/items'

    expect(page).to have_css("#merchant-item-#{stache.id}")
    expect(page).to have_css("#merchant-item-#{pugtato.id}")

    within "#merchant-item-#{stache.id}" do
      expect(page).to have_link('Deactivate Item')
      expect(page).to have_content('active')

      click_link('Deactivate Item')

      expect(page).to have_link('Activate Item')
      expect(page).to have_content('inactive')

      click_link('Activate Item')
      
      expect(page).to have_link('Deactivate Item')
      expect(page).to have_content('active')
    end
  end
end
