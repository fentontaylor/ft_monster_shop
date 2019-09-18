class Merchant::ItemsController < Merchant::BaseController
  before_action :require_merchant, only: [:new, :edit]
  before_action :set_item, only: [:update_activity, :edit, :update, :destroy]

  def new
    user = User.find(session[:user_id])
    @merchant = user.merchant
    @item = @merchant.items.new
  end

  def create
    user = User.find(session[:user_id])
    @merchant = user.merchant
    @item = @merchant.items.create(item_params)
    if @item.image == ""
      @item.update(image: "https://i.ibb.co/0jybzgd/default-thumbnail.jpg")
    end
    if @item.save
      flash[:success] = "#{@item.name} has been added"
      redirect_to "/merchant/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    @item.update(item_params)
    if @item.image == ""
        @item.update(image: "https://i.ibb.co/0jybzgd/default-thumbnail.jpg")
    end
    if @item.save
        flash[:success] = "#{@item.name} has been updated"
      redirect_to "/merchant/items"
    else
      flash[:error] = @item.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @item.reviews.destroy_all
    @item.destroy
    flash[:success] = "#{@item.name} has been deleted"
    redirect_to "/merchant/items"
  end

  def fulfill_item
    order = Order.find(params[:order_id])
    item_order = ItemOrder.find_by(order_id: order.id, item_id: params[:item_id])
    item = Item.find(item_order.item_id)
    item.fulfill(item_order.quantity)
    item_order.fulfill
    order.update_status
    flash[:success] = "#{item.name} has been fulfilled"
    redirect_to "/merchant/orders/#{item_order.order_id}"
  end

  def update_activity
    @item.update_activity
    flash[:success] = "#{@item.name} has been updated"
    redirect_to "/merchant/items"
  end

  private

  def set_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name,:description,:price,:inventory,:image)
  end

  def require_merchant
    render file: "/public/404", status: 404 unless current_merchant? || current_admin?
  end
end
