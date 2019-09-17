require 'rails_helper'

describe Review, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :content }
    it { should validate_numericality_of :rating }
  end

  describe "relationships" do
    it { should belong_to :item }
    it { should belong_to :user }
  end

  describe 'instance methods' do
    it '#written_by?' do
      user_1 = create(:user)
      user_2 = create(:user)

      merchant = create(:merchant)
      item = create(:item)
      merchant.items << item

      review = Review.create(title: 'Cool', content: 'I like it', rating: 4, item: item, user: user_1)

      expect(review.written_by? user_1).to be(true)
      expect(review.written_by? user_2).to be(false)
    end
  end
end
