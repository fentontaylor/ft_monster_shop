class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :update_password]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}!"
      redirect_to "/profile"
    else
      flash[:error] = @user.errors.full_messages.uniq.to_sentence
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      flash[:success] = 'Profile updated'
      redirect_to '/profile'
    else
      flash[:error] = @user.errors.full_messages.uniq.to_sentence
      redirect_to '/profile/edit'
    end
  end

  def show
    unless session[:user_id]
      render file: "/public/404", status: 404
    else
      if params[:id] && current_admin?
        @user = User.find(params[:id])
        @admin = User.find_by(id: session[:user_id])
      else
        @user = User.find_by(id: session[:user_id])
      end
    end
  end

  def edit_password
  end

  def update_password
    if @user.authenticate(old_password)
      if new_passwords_match?
        @user.password = new_password
        @user.save
        flash[:success] = 'You got a fresh new password, dawg!'
        redirect_to '/profile'
      else
        flash[:error] = "Your new password didn't match the confirmation"
        redirect_to '/profile/edit_password'
      end
    else
      flash[:error] = "Your old password didn't match the one on record"
      redirect_to '/profile/edit_password'
    end

  end

  private

  def set_user
    @user = User.find(session[:user_id])
  end

  def update_password_params
    params.require(:update_password).permit(:old_password, :new_password, :new_password_confirmation)
  end

  def old_password
    update_password_params[:old_password]
  end

  def new_password
    update_password_params[:new_password]
  end

  def new_passwords_match?
    update_password_params[:new_password] == update_password_params[:new_password_confirmation]
  end

  def user_params
    params.require(:user).permit(:name,:address,:city,:state,:zip,:email,:password,:password_confirmation)
  end

  def profile_params
    params.require(:users_edit).permit(:name,:address,:city,:state,:zip,:email)
  end
end
