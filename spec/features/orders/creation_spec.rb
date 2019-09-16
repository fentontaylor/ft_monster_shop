describe("Order Creation") do
  describe "When I check out from my cart" do
    before :each do
      @tire = create(:item, price: 10)
      @paper = create(:item, price: 5)
      @pencil = create(:item, price: 1)
      @user = create(:user)

      visit '/login'

      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password

      within '#login-form' do
        click_on 'Log In'
      end

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"

      visit "/cart"
      click_on "Checkout"
    end

    it 'I can create a new order' do
      expect(page).to have_link('Create Order')

      click_link 'Create Order'

      new_order = Order.last

      expect(current_path).to eq("/profile/orders")

      expect(page).to have_content('Thank You For Your Order!')
      expect(page).to have_content(new_order.updated_at.strftime('%D'))
      expect(page).to have_content(new_order.status)
      expect(page).to have_content(new_order.items_count)
      expect(page).to have_content("$21.00")
      expect(page).to have_content(new_order.created_at.strftime('%D'))
    end
  end
end
