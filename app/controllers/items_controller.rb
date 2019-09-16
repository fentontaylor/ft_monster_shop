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

  private

  def item_params
    params.permit(:name,:description,:price,:inventory,:image)
  end

  def require_merchant
    render file: "/public/404" unless current_merchant? || current_admin?
  end
end
