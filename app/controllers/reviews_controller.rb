class ReviewsController < ApplicationController
  def new
    @item = Item.find(params[:item_id])
  end

  def create
    @item = Item.find(params[:item_id])
    @review = @item.reviews.create(review_params)
    if @review.save
      flash[:success] = "Thanks for ur opinion, dawg"
      redirect_to item_path(@item)
    else
      flash[:error] = @review.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @review = Review.find(params[:id])
  end

  def update
    review = Review.find(params[:id])
    review.update(review_params)
    redirect_to "/items/#{review.item.id}"
  end

  def destroy
    review = Review.find(params[:id])
    item = review.item
    review.destroy
    redirect_to "/items/#{item.id}"
  end

  private

  def review_params
    params.permit(:title,:content,:rating)
  end
end
