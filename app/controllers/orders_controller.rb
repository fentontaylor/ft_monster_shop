class OrdersController < ApplicationController
  before_action :set_user, only: [:index, :show, :new, :create]
  before_action :set_order, only: [:show, :edit, :update, :cancel, :ship]

  def index
  end

  def show
  end

  def new
    @addresses = @user.addresses
    @selected = Address.find_by(nickname: params[:address])
  end

  def create
    order = @user.orders.create(user_info(@user))
    create_item_orders(order)
    session.delete(:cart)
    redirect_to "/profile/orders"
    flash[:success] = "Thankz for your business, dawg!"
  end

  def edit
  end

  def update
    if @order.update(order_params)
      flash[:success] = "You updated yo' shipping deets"
      redirect_to order_path(@order)
    else
      flash[:error] = @order.errors.full_messages.to_sentence
      redirect_to edit_order_path(@order)
    end
  end

  def create_item_orders(order)
    cart.items.each do |item,quantity|
      order.item_orders.create({
        item: item,
        quantity: quantity,
        price: item.price
        })
    end
  end

  def cancel
    cancel_item_orders(@order)
    @order.status = "cancelled"
    @order.save
    if current_admin?
      flash[:success] = "You destroyed the users order dawg"
      redirect_to "/admin"
    else
      flash[:success] = "Your order has been cancelled dawg"
      redirect_to "/profile"
    end
  end

  def cancel_item_orders(order)
    order.item_orders.each do |item_order|
      item_order.status = "unfulfilled"
      item = Item.find(item_order.item_id)
      item.restock(item_order.quantity)
      item_order.save
    end
  end

  def ship
    @order.update(status: 'shipped')
    @order.save
    flash[:success] = "Order No. #{@order.id} has been shipped, yo!"
    redirect_to "/admin"
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_user
    unless current_admin?
      @user = User.find(session[:user_id])
    else
      @user = User.find(params[:user_id])
    end
  end

  def user_info(user)
    info = Hash.new
    address = user.addresses.find(params[:address_id])
    info[:name] = user.name
    info[:address] = address.address
    info[:city] = address.city
    info[:state] = address.state
    info[:zip] = address.zip
    info
  end

  def order_params
    params.require(:order).permit(:name, :address, :city, :state, :zip)
  end
end
