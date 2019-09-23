class MerchantsController < ApplicationController
  before_action :valid_merchant, only: [:show]
  before_action :set_merchant, only: [:show, :edit, :update, :destroy]

  def index
    if current_admin? == false
      @merchants = Merchant.all.where(status: 0)
    else
      @merchants = Merchant.all
    end
  end

  def show
    if current_merchant?
      @works_here = @merchant.works_here?(current_user.merchant.id)
    end
  end

  def new
  end

  def create
    merchant = Merchant.create(merchant_params)
    if merchant.save
      redirect_to "/merchants"
    else
      flash[:error] = merchant.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    user = User.find(session[:user_id])
    render file: "/public/404", status: 404 unless current_merchant_admin? && @merchant.works_here?(user.merchant.id)
  end

  def update
    @merchant.update(merchant_params)
    if @merchant.save
      redirect_to "/merchants/#{@merchant.id}"
    else
      flash[:error] = @merchant.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @merchant.destroy
    redirect_to '/merchants'
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:id])
  end

  def merchant_params
    params.permit(:name,:address,:city,:state,:zip)
  end

  def valid_merchant
    render file: "/public/404", status: 404 unless Merchant.find(params[:id]).status == 'enabled'
  end
end
