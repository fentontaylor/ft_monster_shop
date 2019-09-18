require 'rails_helper'

RSpec.describe 'review edit and update', type: :feature do
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

  describe "Visitor views an item show page" do
    it "They see no links to edit reviews" do
      visit "/items/#{@chain.id}"

      @all_reviews.each do |review|
        within "#review-#{review.id}" do
          expect(page).to_not have_link("Edit")
        end
      end
    end

    it "Logged in user can edit only reviews they wrote" do
      title = "Edited Title"
      content = "Updated content"
      rating = 4

      visit '/login'

      within "#login-form" do
        fill_in 'Email', with: @user_1.email
        fill_in 'Password', with: @user_1.password
        click_on 'Log In'
      end

      visit "/items/#{@chain.id}"

      within "#review-#{@review_2.id}" do
        expect(page).to_not have_link('Edit')
      end

      within "#review-#{@review_3.id}" do
        expect(page).to_not have_link('Edit')
      end

      within "#review-#{@review_1.id}" do
        expect(page).to have_link('Edit')
        click_on "Edit"
      end

      expect(current_path).to eq(edit_item_review_path(@chain, @review_1))
      expect(find_field('Title').value).to eq(@review_1.title)
      expect(find_field('Content').value).to eq(@review_1.content)
      expect(find_field('Rating').value).to eq(@review_1.rating.to_s)

      fill_in 'Title', with: title
      fill_in 'Content', with: content
      fill_in 'Rating', with: rating

      click_on "Update Review"

      expect(current_path).to eq("/items/#{@chain.id}")

      expect(page).to have_content('Updated your review, dawg!')

      within "#review-#{@review_1.id}" do
        expect(page).to have_content(title)
        expect(page).to have_content(content)
        expect(page).to have_content(rating)
      end
    end

    it "Logged in user can edit their review by changing just some fields" do
      visit '/login'

      within "#login-form" do
        fill_in 'Email', with: @user_1.email
        fill_in 'Password', with: @user_1.password
        click_on 'Log In'
      end

      visit "/items/#{@chain.id}"

      within "#review-#{@review_1.id}" do
        click_on "Edit"
      end

      title = 'Edited Title'
      fill_in 'Title', with: title

      click_on "Update Review"

      expect(current_path).to eq("/items/#{@chain.id}")

      within "#review-#{@review_1.id}" do
        expect(page).to have_content(title)
        expect(page).to have_content(@review_1.content)
        expect(page).to have_content(@review_1.rating)
      end
    end

    it "Cannot submit form with empty fields" do
      visit '/login'

      within "#login-form" do
        fill_in 'Email', with: @user_1.email
        fill_in 'Password', with: @user_1.password
        click_on 'Log In'
      end

      visit "/items/#{@chain.id}"

      within "#review-#{@review_1.id}" do
        click_on "Edit"
      end

      fill_in 'Title', with: nil
      fill_in 'Content', with: nil
      fill_in 'Rating', with: nil

      click_on "Update Review"

      expect(page).to have_content("Edit Review for #{@chain.name}")
      expect(page).to have_content("Title can't be blank, Content can't be blank, and Rating is not a number")
    end
  end
end
