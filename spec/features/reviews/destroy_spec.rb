require 'rails_helper'

RSpec.describe 'review edit and update', type: :feature do
  before(:each) do
    @user_1 = create(:user)
    @user_2 = create(:user)

    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

    @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5, user: @user_1)
    @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4, user: @user_2)

  end

  describe "when a person visits the item show page" do
    it 'Visitors dont see links to delete reviews' do
      visit item_path(@chain)

      [@review_1, @review_2].each do |rev|
        within "#review-#{rev.id}" do
          expect(page).to_not have_link("Delete")
        end
      end
    end

    it "User sees link to only delete their review, and clicking the link deletes it" do
      visit '/login'

      within "#login-form" do
        fill_in 'Email', with: @user_1.email
        fill_in 'Password', with: @user_1.password
        click_on 'Log In'
      end

      visit item_path(@chain)

      within "#review-#{@review_2.id}" do
        expect(page).to_not have_link("Delete")
      end

      within "#review-#{@review_1.id}" do
        expect(page).to have_link("Delete")
        click_link 'Delete'
      end

      expect(page).to_not have_css("#review-#{@review_1.id}")
    end
  end
end
