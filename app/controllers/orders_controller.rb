class OrdersController < ApplicationController
  before_action :set_user, only: [:index, :show, :new, :create, :edit, :cancel]
  before_action :set_order, only: [:show, :edit, :update, :cancel, :ship]
  before_action :authorized_to_change?, only: [:edit, :update, :cancel]

  def index
  end

  def show
  end

  def new
    @addresses = @user.addresses
    session[:address] = Address.find_by(id: params[:address])
    @selected = session[:address]
  end

  def create
    order = @user.orders.create(address_info)
    create_item_orders(order)
    session.delete(:cart)
    session.delete(:address)
    redirect_to "/profile/orders"
    flash[:success] = "Thankz for your business, dawg!"
  end

  def edit
    unless @order.pending?
      render file: 'public/404', status: 404
    end
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

  def authorized_to_change?
    unless @order.placed_by?(current_user) || current_admin?
      render file: 'public/403', status: 403
    end
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def set_user
    unless current_admin?
      @user = User.find(session[:user_id])
    else
      @user = User.find_by_id(params[:user_id])
    end
  end

  def address_info
    ['id', 'nickname', 'user_id'].each { |k| session[:address].delete k }
    session[:address]
  end

  def order_params
    params.require(:order).permit(:name, :address, :city, :state, :zip)
  end
end
