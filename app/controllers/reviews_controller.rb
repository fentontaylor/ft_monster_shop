class ReviewsController < ApplicationController
  before_action :visitor_redirect
  before_action :set_item, only: [:new, :create, :edit]
  before_action :set_review, only: [:edit, :update, :destroy]
  def new
    @review = @item.reviews.new
  end

  def create
    full_params = review_params.to_h
    full_params[:user_id] = session[:user_id]
    @review = @item.reviews.create(full_params)
    if @review.save
      flash[:success] = "Thanks for ur opinion, dawg"
      redirect_to item_path(@item)
    else
      flash[:error] = @review.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      flash[:success] = 'Updated your review, dawg!'
      redirect_to "/items/#{@review.item.id}"
    else
      flash[:error] = @review.errors.full_messages.to_sentence
      redirect_to edit_item_review_path(@review.item, @review)
    end
  end

  def destroy
    item = @review.item
    @review.destroy
    redirect_to "/items/#{item.id}"
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def review_params
    params.require(:review).permit(:title,:content,:rating)
  end
end
