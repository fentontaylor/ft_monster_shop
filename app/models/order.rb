class Order <ApplicationRecord
  validates_presence_of :name, :address, :city, :state, :zip, :status

  has_many :item_orders
  has_many :items, through: :item_orders
  belongs_to :user

  enum status: { pending: 0, packaged: 1, shipped: 2 , cancelled: 3 }

  def grandtotal
    item_orders.sum('price * quantity')
  end

  def items_count
    item_orders.sum(:quantity)
  end

  def my_items_count(merchant_id)
    item_orders.joins(:item).where("items.merchant_id = #{merchant_id}").sum("item_orders.quantity")
  end

  def my_total(merchant_id)
    item_orders.joins(:item).where("items.merchant_id = #{merchant_id}").sum("item_orders.quantity * item_orders.price")
  end

  def merchant_items(merchant)
    items.where(merchant_id: merchant.id)
  end

  def qty_item_in_order(item)
    item_orders.find_by(item_id: item.id).quantity
  end

  def find_item_status(item)
    item_orders.find_by(item_id: item.id).status
  end

  def update_status
    self.update(status: 1) if item_orders.pluck(:status).all? {|status| status == "fulfilled"}
  end

  def placed_by?(user)
    self.user_id == user.id
  end
end
