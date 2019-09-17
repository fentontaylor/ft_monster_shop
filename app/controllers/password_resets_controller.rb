class PasswordResetsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user
      user.send_password_reset
      flash[:success] = "We sent you an email with instructions!"
      redirect_to "/login"
    else
      flash[:error] = "That email ain't in our system"
      redirect_to '/password_resets/new'
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      @user.save
      flash[:success] = "Password has been reset!"
      redirect_to "/login"
    else
      render :edit
    end
  end

end
