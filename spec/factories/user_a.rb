FactoryBot.define do
  factory :user_a do
    before(:create) do |user|
      user.addresses << create(:address, user: user)
    end
    sequence(:name) {|x| "Name #{x}"}
    sequence(:email) {|x| "email_#{x}@email.com"}
    sequence(:password) {|x| "password#{x}"}
    role { 1 }
    association :merchant, factory: :merchant
  end
end
