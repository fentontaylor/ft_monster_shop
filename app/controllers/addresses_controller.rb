class AddressesController < ApplicationController
  def new
    @user = User.find(params[:id])
    @address = @user.addresses.new
  end
end
