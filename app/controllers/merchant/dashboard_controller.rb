class Merchant::DashboardController < Merchant::BaseController

  def index
    if current_admin?
      render file: "/public/404"
    else
      @user = User.find(session[:user_id])
      @merchant = @user.merchant
      @pending_orders = @merchant.pending_orders
      session[:merchant_id] = @merchant.id
    end
  end

  def items
    if current_admin?
      @merchant = Merchant.find(session[:merchant_id])
      @items = @merchant.items
    else
      user = User.find(session[:user_id])
      @merchant = user.merchant
      @items = @merchant.items
    end
  end

  def order_show
    if current_admin?
      @order = Order.find(params[:id])
      @merchant = Merchant.find(session[:merchant_id])
      @merchant_items = @order.merchant_items(@merchant)
    else
      @order = Order.find(params[:id])
      user = User.find(session[:user_id])
      @merchant_items = @order.merchant_items(user.merchant)
    end
  end

end
