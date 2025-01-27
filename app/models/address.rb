class Address < ApplicationRecord
  validates_presence_of :nickname
  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip

  belongs_to :user
end
