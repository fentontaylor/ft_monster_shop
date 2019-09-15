require 'rails_helper'

describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
    it { should validate_presence_of :status }
  end

  describe "relationships" do
    it {should have_many :items}
    it {should have_many :users}
  end

  describe 'instance methods' do
    before(:each) do
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
    end

    it "works here" do
      sue = @meg.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)

      expect(@meg.works_here?(sue.merchant.id)).to be true
    end

    it '#no_orders' do
      expect(@meg.no_orders?).to eq(true)

      user = create(:user)
      order_1 = user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      item_order_1 = order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)

      expect(@meg.no_orders?).to eq(false)
    end

    it '#item_count' do
      chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 30, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 22)

      expect(@meg.item_count).to eq(2)
    end

    it '#average_item_price' do
      chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 40, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 22)

      expect(@meg.average_item_price).to eq(70)
    end

    it '#distinct_cities' do
      chain = @meg.items.create(name: "Chain", description: "It'll never break!", price: 40, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 22)
      user = create(:user)
      order_1 = user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      order_2 = user.orders.create!(name: 'Brian', address: '123 Brian Ave', city: 'Denver', state: 'CO', zip: 17033)
      order_3 = user.orders.create!(name: 'Dao', address: '123 Mike Ave', city: 'Denver', state: 'CO', zip: 17033)
      order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      order_2.item_orders.create!(item: chain, price: chain.price, quantity: 2)
      order_3.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)

      expect(@meg.distinct_cities.sort).to eq(["Denver","Hershey"])
    end

    it '#pending_orders' do
      user = create(:user)
      order_1 = user.orders.create!(name: 'Meg', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)
      order_2 = user.orders.create!(name: 'Brian', address: '123 Brian Ave', city: 'Denver', state: 'CO', zip: 17033)
      order_3 = user.orders.create!(name: 'Dao', address: '123 Mike Ave', city: 'Denver', state: 'CO', zip: 17033, status: 2)
      order_1.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      order_2.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)
      order_3.item_orders.create!(item: @tire, price: @tire.price, quantity: 2)

      expect(@meg.pending_orders).to eq([order_1, order_2])
    end

    it '#disable' do
      expect(@meg.status).to eq('enabled')

      @meg.disable

      expect(@meg.status).to eq('disabled')
    end

    it '#enable' do
      @meg.disable
      @meg.enable

      expect(@meg.status).to eq('enabled')
    end

    it '#top_or_bottom_5' do
      user = create(:user)

      item_1 = create(:item, merchant: @meg)
      item_2 = create(:item, merchant: @meg)
      item_3 = create(:item, merchant: @meg)
      item_4 = create(:item, merchant: @meg)
      item_5 = create(:item, merchant: @meg)
      item_6 = create(:item, merchant: @meg)

      order = user.orders.create(name: 'Jack', address: '123 Stang Ave', city: 'Hershey', state: 'PA', zip: 17033)

      order.item_orders.create(item: item_1, price: item_1.price, quantity: 10)
      order.item_orders.create(item: item_2, price: item_2.price, quantity: 20)
      order.item_orders.create(item: item_3, price: item_3.price, quantity: 30)
      order.item_orders.create(item: item_4, price: item_4.price, quantity: 40)
      order.item_orders.create(item: item_5, price: item_5.price, quantity: 50)
      order.item_orders.create(item: item_6, price: item_6.price, quantity: 60)

      top = @meg.top_or_bottom_5('desc')
      bottom = @meg.top_or_bottom_5('asc')

      expect(top).to eq([item_6, item_5, item_4, item_3, item_2])

      expect(bottom).to eq([@tire, item_1, item_2, item_3, item_4])
    end
  end
end
