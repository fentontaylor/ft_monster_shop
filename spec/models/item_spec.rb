require 'rails_helper'

describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price }
    it { should validate_presence_of :image }
    it { should validate_numericality_of :inventory }
  end

  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :reviews }
    it { should have_many :item_orders }
    it { should have_many(:orders).through(:item_orders) }
  end

  describe 'class methods' do
    it '::top_or_bottom_5' do
      user = create(:user)

      item_1 = create(:item)
      item_2 = create(:item)
      item_3 = create(:item)
      item_4 = create(:item)
      item_5 = create(:item)
      item_6 = create(:item)
      item_7 = create(:item)

      order = user.orders.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)

      order.item_orders.create(item: item_1, price: item_1.price, quantity: 10)
      order.item_orders.create(item: item_2, price: item_2.price, quantity: 20)
      order.item_orders.create(item: item_3, price: item_3.price, quantity: 30)
      order.item_orders.create(item: item_4, price: item_4.price, quantity: 40)
      order.item_orders.create(item: item_5, price: item_5.price, quantity: 50)
      order.item_orders.create(item: item_6, price: item_6.price, quantity: 60)
      order.item_orders.create(item: item_7, price: item_7.price, quantity: 70)

      top = Item.top_or_bottom_5('desc')
      expect(top).to eq([item_7, item_6, item_5, item_4, item_3])

      bottom = Item.top_or_bottom_5('asc')
      expect(bottom).to eq([item_1, item_2, item_3, item_4, item_5])
    end

    it '::active_items' do
      item_1 = create(:item, active?: false)
      item_2 = create(:item)
      item_3 = create(:item)

      expect(Item.active_items).to eq([item_2, item_3])
    end
  end

  describe "instance methods" do
    before(:each) do
      @user = create(:user)
      @bike_shop = Merchant.create(name: "Brian's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @chain = @bike_shop.items.create(name: "Chain", description: "It'll never break!", price: 50, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)
      @bike = @bike_shop.items.create(name: "Bike", description: "It'll never break!", price: 100, image: "https://www.rei.com/media/b61d1379-ec0e-4760-9247-57ef971af0ad?size=784x588", inventory: 5)

      @review_1 = @chain.reviews.create(title: "Great place!", content: "They have great bike stuff and I'd recommend them to anyone.", rating: 5, user: @user)
      @review_2 = @chain.reviews.create(title: "Cool shop!", content: "They have cool bike stuff and I'd recommend them to anyone.", rating: 4, user: @user)
      @review_3 = @chain.reviews.create(title: "Meh place", content: "They have meh bike stuff and I probably won't come back", rating: 1, user: @user)
      @review_4 = @chain.reviews.create(title: "Not too impressed", content: "v basic bike shop", rating: 2, user: @user)
      @review_5 = @chain.reviews.create(title: "Okay place :/", content: "Brian's cool and all but just an okay selection of items", rating: 3, user: @user)
    end

    it "calculate average review" do
      expect(@chain.average_review).to eq(3.0)
    end

    it "sorts reviews" do
      top_three = @chain.sorted_reviews(3,:desc)
      bottom_three = @chain.sorted_reviews(3,:asc)

      expect(top_three).to eq([@review_1,@review_2,@review_5])
      expect(bottom_three).to eq([@review_3,@review_4,@review_5])
    end

    it 'no orders' do
      expect(@chain.no_orders?).to eq(true)
      user = create(:user)
      order = user.orders.create(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      order.item_orders.create(item: @chain, price: @chain.price, quantity: 2)
      expect(@chain.no_orders?).to eq(false)
    end

    it "fulfill" do
      @chain.fulfill(5)
      expect(@chain.inventory).to eq(0)
      expect(@chain.active?).to eq(false)
    end

    it "restock" do
      @chain.fulfill(5)
      @chain.restock(5)
      expect(@chain.inventory).to eq(5)
      expect(@chain.active?).to eq(true)
    end

    it "update_activity" do
      @chain.update_activity

      expect(@chain.active?).to be false

      @chain.update_activity

      expect(@chain.active?).to be true
    end
  end
end
