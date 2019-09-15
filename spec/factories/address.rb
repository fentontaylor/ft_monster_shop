FactoryBot.define do
  factory :address do
    sequence(:name) {|x| "Name #{x}"}
    sequence(:address) {|x| "#{x.to_s * 3} Fake St"}
    sequence(:city) {|x| "Unreal City #{x}"}
    state {'CO'}
    zip {'80010'}
    sequence(:nickname) {|x| "My Address #{x}"}
    user
  end
end
