class ItemsController < ApplicationController
  before_action :require_merchant, only: [:new, :edit]

  def index
    if params[:merchant_id]
      @merchant = Merchant.find(params[:merchant_id])
      @items = @merchant.items
      @top_5 = @merchant.top_or_bottom_5('desc')
      @bottom_5 = @merchant.top_or_bottom_5('asc')
    else
      @items = Item.active_items
      @top_5 = Item.top_or_bottom_5('desc')
      @bottom_5 = Item.top_or_bottom_5('asc')
    end
  end

  def show
    @item = Item.find(params[:id])
  end

  # def edit
  #   @item = Item.find(params[:id])
  # end
  #
  # def update
  #   @item = Item.find(params[:id])
  #   @item.update(item_params)
  #   if @item.save
  #     redirect_to "/items/#{@item.id}"
  #   else
  #     flash[:error] = @item.errors.full_messages.to_sentence
  #     redirect_to
  #   end
  # end
  #
  # def destroy
  #   item = Item.find(params[:id])
  #   Review.where(item_id: item.id).destroy_all
  #   item.destroy
  #   redirect_to "/items"
  # end

  private

  def item_params
    params.permit(:name,:description,:price,:inventory,:image)
  end

  def require_merchant
    render file: "/public/404" unless current_merchant? || current_admin?
  end
end
