require 'rails_helper'

describe 'Admin views item show page' do
  before(:each) do
    @user_1 = create(:user)
    @user_2 = create(:user)
    @user_3 = create(:user)

    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

    @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5, user: @user_1)
    @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4, user: @user_2)
    @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1, user: @user_3)

    @all_reviews = [@review_1,@review_2,@review_3]
  end

  it 'admin can edit or delete all reviews' do
    admin = create(:user, role: 4)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: admin.password
      click_on 'Log In'
    end

    visit item_path(@chain)

    @all_reviews.each do |rev|
      within "#review-#{rev.id}" do
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end

    within "#review-#{@review_1.id}" do
      click_link 'Edit'
    end

    fill_in 'Title', with: 'Edited Title'

    click_on 'Update Review'

    within "#review-#{@review_1.id}" do
      expect(page).to have_content('Edited Title')
    end

    within "#review-#{@review_2.id}" do
      click_link 'Delete'
    end

    expect(page).to_not have_css("#review-#{@review_2.id}")
  end
end
