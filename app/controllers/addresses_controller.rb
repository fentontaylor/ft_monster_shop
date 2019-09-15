class AddressesController < ApplicationController
  before_action :set_user, only: [:new, :create, :edit, :update, :destroy]

  def new
    @address = @user.addresses.new
  end

  def create
    @address = @user.addresses.new(address_params)
    if @address.save
      redirect_to "/profile"
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit

  end

  def update

  end

  def destroy

  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def address_params
    params.require(:address).permit(:nickname, :name, :address, :city, :state, :zip)
  end
end
