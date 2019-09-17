require 'rails_helper'

RSpec.describe 'review creation', type: :feature do
  before(:each) do
    @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
    @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
    @user = create(:user)

    visit '/login'

    within "#login-form" do
      fill_in 'Email', with: @user.email
      fill_in 'Password', with: @user.password
      click_on 'Log In'
    end
  end

  describe "when I visit the item show page" do
    it 'I see a link to add a review for that item' do
      visit "items/#{@chain.id}"

      expect(page).to have_link("Add Review")

      click_on "Add Review"

      expect(current_path).to eq("/items/#{@chain.id}/reviews/new")
    end

    describe "and click on a link to add a review" do
      it "I can create a new review by following the link" do
        title = "Thanks Brian's Bike Shop!"
        content = "Took my bike in for a service and all is working well!"
        rating = 5

        visit "/items/#{@chain.id}"

        click_on "Add Review"

        fill_in 'Title', with: title
        fill_in 'Content', with: content
        fill_in 'Rating', with: rating

        click_button "Create Review"
        
        last_review = Review.last
        expect(current_path).to eq("/items/#{@chain.id}")
        expect(last_review.title).to eq(title)
        expect(last_review.content).to eq(content)
        expect(last_review.rating).to eq(rating)

        within "#review-#{last_review.id}" do
          expect(page).to have_content(title)
          expect(page).to have_content(content)
          expect(page).to have_content("Rating: #{rating}/5")
        end
      end

      it "I cannot create a review unless I complete the whole form" do
        title = "Thanks Brian's Bike Shop!"
        rating = 5

        visit "/items/#{@chain.id}"

        click_on "Add Review"

        click_on "Create Review"

        expect(page).to have_content("Title can't be blank, Content can't be blank, and Rating is not a number")
        expect(page).to have_content("Create Review for #{@chain.name}")
      end

      it 'I get an error if my rating is not between 1 and 5' do
        title = "Thanks Brian's Bike Shop!"
        content = "SO FUN SO GREAT"

        visit "/items/#{@chain.id}"

        click_on "Add Review"

        fill_in 'Title', with: title
        fill_in 'Content', with: content
        fill_in 'Rating', with: 0

        click_on "Create Review"

        expect(page).to have_content("Rating must be greater than or equal to 1")
        expect(page).to have_button "Create Review"

        fill_in 'Title', with: title
        fill_in 'Content', with: content
        fill_in 'Rating', with: 6

        click_on "Create Review"

        expect(page).to have_content("Rating must be less than or equal to 5")
        expect(page).to have_button "Create Review"
      end
    end
  end
end

describe 'Unregistered Visitor' do
  it 'Cannot create reviews' do
    merchant = create(:merchant)
    item = create(:item)
    merchant.items << item
    visit "items/#{item.id}"

    expect(page).to_not have_link("Add Review")
  end
end
