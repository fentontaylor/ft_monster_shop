class AddressesController < ApplicationController
  before_action :set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_address, only: [:edit, :update, :destroy]

  def new
    @address = @user.addresses.new
  end

  def create
    @address = @user.addresses.new(address_params)
    if @address.save
      flash[:success] = "#{@address.nickname} address added"
      redirect_to "/profile"
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    @address.update(address_params)
    if @address.save
      flash[:success] = "#{@address.nickname} address updated"
      redirect_to '/profile'
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      redirect_to user_address_edit_path(@user, @address)
    end
  end

  def destroy

  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_address
    @address = Address.find(params[:address_id])
  end

  def address_params
    params.require(:address).permit(:nickname, :name, :address, :city, :state, :zip)
  end
end
