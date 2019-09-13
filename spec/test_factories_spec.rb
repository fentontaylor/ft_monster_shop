require 'rails_helper'

describe 'factory test' do
  it "test" do
    user = create(:user)
    user2 = create(:user)
    address = create(:address, user: user)
    address2 = create(:address, user: user)
    address3 = create(:address, user: user2)

    address4 = create(:address)
    binding.pry
  end
end
