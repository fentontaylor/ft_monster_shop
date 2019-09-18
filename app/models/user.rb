class User < ApplicationRecord
  before_create { generate_token(:auth_token) }
  validates_presence_of :name
  validates_confirmation_of :password, require: true
  validates :email, presence: true, uniqueness: true
  validates :role, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  has_many :reviews
  has_many :orders
  has_many :addresses, dependent: :destroy
  belongs_to :merchant, optional: true

  enum role: { user: 1, merchant_employee: 2, merchant_admin: 3, admin: 4 }

  has_secure_password

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def works_here?(id)
    self.merchant.id == id
  end
end
