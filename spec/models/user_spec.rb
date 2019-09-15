require 'rails_helper'

describe User, type: :model do
  describe "validations" do
    it {should validate_presence_of(:email)}
    it {should validate_uniqueness_of(:email)}
    it {should validate_confirmation_of(:password)}
    it {should validate_presence_of(:name)}
    it {should allow_value(nil).for(:merchant)}
  end

  describe "relationships" do
    it {should have_many :orders}
    it {should have_many :addresses}
  end

  describe "model methods" do
    before :each do
      @dog_shop = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
      @sue = @dog_shop.users.create(name: 'Sue', email: 'sue@email.com', password: 'sue', password_confirmation: 'sue', role: 3)
    end

    it "should confirm if a user works at a merchant" do
      visit "/login"
      fill_in "Email", with: @sue.email
      fill_in "Password", with: @sue.password

      expect(@sue.works_here?(@dog_shop.id)).to be true
    end

    it "send_password_reset" do
      @sue.send_password_reset
    end
  end
end
