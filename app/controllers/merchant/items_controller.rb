class Merchant::ItemsController < Merchant::BaseController

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
      item = Item.find(params[:id])
      item.update_activity
      flash[:success] = "#{item.name} has been updated"
      redirect_to "/merchant/items"
    end

    def destroy
      item = Item.find(params[:id])
      item.reviews.destroy_all
      item.destroy
      flash[:success] = "#{item.name} has been deleted"
      redirect_to "/merchant/items"
    end

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
      @item = Item.find(params[:id])
    end

    def update
      @item = Item.find(params[:id])
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

    private

    def item_params
      params.require(:item).permit(:name,:description,:price,:inventory,:image)
    end
end
