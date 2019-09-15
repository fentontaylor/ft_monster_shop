require 'rails_helper'
describe 'As a visitor or regular user' do
  describe 'I dont have the ability to edit items' do
    before :each do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    end

    it 'Visitor cant see edit item button' do
      visit item_path(@tire)
      expect(page).to_not have_link('Edit Item')
    end

    it 'User cant see edit item button' do
      user = create(:user)

      visit '/'

      within '.login-options' do
        click_on 'Log In'
      end

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password

      within  '#login-form' do
        click_on 'Log In'
      end

      visit item_path(@tire)
      expect(page).to_not have_link('Edit Item')
    end
  end
end
describe "As a merchant admin" do
  describe "When I visit an Item Show Page" do
    describe "and click on edit item" do
      before :each do
        @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
        @m_admin = create(:user, role: 3, merchant_id: @meg.id)
        @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)

        visit '/'

        within '.login-options' do
          click_on 'Log In'
        end

        fill_in 'Email', with: @m_admin.email
        fill_in 'Password', with: @m_admin.password

        within  '#login-form' do
          click_on 'Log In'
        end
      end
      it 'I can see the prepopulated fields of that item' do


        visit "/items/#{@tire.id}"

        expect(page).to have_link("Edit Item")

        click_on "Edit Item"

        expect(current_path).to eq("/merchant/items/#{@tire.id}/edit")
        expect(page).to have_link("Gatorskins")
        expect(find_field('Name').value).to eq "Gatorskins"
        expect(find_field('Price').value).to eq "100"
        expect(find_field('Description').value).to eq "They'll never pop!"
        expect(find_field('Image').value).to eq("https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588")
        expect(find_field('Inventory').value).to eq '12'
      end

      it 'I can change and update item with the form' do
        visit "/items/#{@tire.id}"

        click_on "Edit Item"

        fill_in 'Name', with: "GatorSkins"
        fill_in 'Price', with: 110
        fill_in 'Description', with: "They're a bit more expensive, and they kinda do pop sometimes, but whatevs.. this is retail."
        fill_in 'Image', with: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588"
        fill_in 'Inventory', with: 11

        click_button "Update Item"

        expect(current_path).to eq("/merchant/items")

        within "#merchant-item-#{@tire.id}" do
          expect(page).to have_content("GatorSkins")
          expect(page).to_not have_content("Gatorskins")
          expect(page).to have_content("$110")
          expect(page).to_not have_content("$100")
          expect(page).to have_content("11")
          expect(page).to_not have_content("12")
        end
      end

      it 'I get a flash message if entire form is not filled out' do
        visit "/items/#{@tire.id}"

        click_on "Edit Item"

        fill_in 'Name', with: ""
        fill_in 'Price', with: ""
        fill_in 'Description', with: "They're a bit more expensive, and they kinda do pop sometimes, but whatevs.. this is retail."
        fill_in 'Image', with: ""
        fill_in 'Inventory', with: 11

        click_button "Update Item"

        expect(page).to have_content("Name can't be blank, Price can't be blank, and Price is not a number")
        expect(page).to have_button("Update Item")
      end
    end
  end
end
