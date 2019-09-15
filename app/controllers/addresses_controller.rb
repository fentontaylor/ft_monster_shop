class AddressesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @address = @user.addresses.new
  end

  def create
    @user = User.find(params[:id])
    @address = @user.addresses.new(address_params)
    if @address.save
      redirect_to "/profile"
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :new
    end
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :name, :address, :city, :state, :zip)
  end
end
