class AddressesController < ApplicationController
  before_action :set_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_address, only: [:edit, :update, :destroy]

  def new
    @address = @user.addresses.new
    session[:return_to] = request.referer
  end

  def create
    @address = @user.addresses.new(address_params)
    if @address.save
      flash[:success] = "#{@address.nickname} address added"
      redirect_to session.delete(:return_to)
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    session[:return_to] = request.referer
  end

  def update
    if @address.update(address_params)
      flash[:success] = "#{@address.nickname} address updated"
      redirect_to session.delete(:return_to)
    else
      flash[:error] = @address.errors.full_messages.to_sentence
      redirect_to edit_user_address_path(@user, @address)
    end
  end

  def destroy
    if session[:user_id] == @user.id
      @address.destroy
      flash[:success] = "#{@address.nickname} address has been deleted"
      redirect_to '/profile'
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_address
    @address = Address.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:nickname, :name, :address, :city, :state, :zip)
  end
end
