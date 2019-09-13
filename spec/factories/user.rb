FactoryBot.define do
  factory :user do
    sequence(:name) {|x| "Name #{x}"}
    sequence(:email) {|x| "email_#{x}@email.com"}
    sequence(:password) {|x| "password#{x}"}
    role { 1 }
    association :merchant, factory: :merchant
  end
end
