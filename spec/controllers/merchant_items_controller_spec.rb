require 'rails_helper'

RSpec.describe "Actions in the merchant/items_controller.rb" do
    before :each do
        @dog_shop = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
        @pull_toy = @dog_shop.items.create(name: "Pull Toy", description: "Great pull toy!", price: 10, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 32)

        @user = create(:user)
        @sue = @dog_shop.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)

        @order_1 = @user.orders.create(name: "Evette", address: "123 street", city: "Denver", state: "CO", zip: "12345")
        @io1 = ItemOrder.create(item: @pull_toy, order: @order_1, price: @pull_toy.price, quantity: 5)

        visit "/login"

        fill_in 'Email', with: @sue.email
        fill_in 'Password', with: @sue.password

        within '#login-form' do
            click_on 'Log In'
        end
    end

    describe "fulfilling item button fulfills items" do
        it "should update inventory and change io status" do
            visit "/merchant"
            click_link "Order ##{@order_1.id}"
            click_on "Fulfill"

            expect(page).to have_content("#{@pull_toy.name} has been fulfilled")
            expect(page).to have_content("Dis item been fulfilled, yo.")
            expect(@order_1.find_item_status(@pull_toy)).to eq('fulfilled')
        end
    end

    describe "merchant updates item activity" do
        it "should change from active to inactive" do
            visit "/merchant/items"

            expect(@pull_toy.active?).to be true

            click_link "Deactivate Item"

            expect(page).to have_content("#{@pull_toy.name} has been updated")
            expect(page).to have_content("inactive")
        end
    end

    describe "merchant deletes an item" do
        it "should delete items that have not been ordered" do
            not_pull_toy = @dog_shop.items.create(name: "some other dog toy", description: "bad toy do not buy", price: 100, image: "http://lovencaretoys.com/image/cache/dog/tug-toy-dog-pull-9010_2-800x800.jpg", inventory: 300)

            visit "/merchant/items"
            expect(page).to have_content(@pull_toy.name)
            expect(page).to have_content(not_pull_toy.name)
            expect(page).to have_content("This item has been ordered.")
            expect(page).to have_content(not_pull_toy.name)
            expect(page).to have_content(not_pull_toy.inventory)

            click_on "Delete Item"

            expect(page).to have_content("#{not_pull_toy.name} has been deleted")
            expect(page).to_not have_content(not_pull_toy.inventory)
        end
    end

    describe "merchant edits an item" do
        it "should bring user to the edit form" do

            visit "/merchant/items"

            click_on "Edit #{@pull_toy.name}"

            expect(current_path).to eq("/merchant/items/#{@pull_toy.id}/edit")
        end

        it "should edit the item with all info except image" do
            visit "/merchant/items/#{@pull_toy.id}/edit"

            fill_in "Inventory", with: 999
            fill_in "Image", with: ""

            click_on "Update Item"

            expect(current_path).to eq("/merchant/items")
            expect(page).to have_content(999)
            expect(page).to have_content("#{@pull_toy.name} has been updated")
        end

        it "will not edit the item with bad info but a blank image is ok" do
            visit "/merchant/items/#{@pull_toy.id}/edit"

            fill_in "Inventory", with: -6
            fill_in "Name", with: ""
            fill_in "Image", with: ""

            click_on "Update Item"

            expect(page).to have_content("Name can't be blank and Inventory must be greater than or equal to 0")
        end
    end
end
