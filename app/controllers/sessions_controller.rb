class SessionsController < ApplicationController
  def new
    if current_user
      flash[:success] = 'Silly pup, you are already logged in!'
      if current_admin?
        redirect_to '/admin'
      elsif current_merchant?
        redirect_to '/merchant'
      else
        redirect_to '/profile'
      end
    end
  end

  def login
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:success] = "Welcome, #{user.name}"
      cookies[:auth_token] = user.auth_token
      if current_admin?
        redirect_to '/admin'
      elsif current_merchant?
        redirect_to '/merchant'
      else
        redirect_to '/profile'
      end
    else
      flash[:error] = "Invalid Email or Password"
      redirect_to '/login'
    end
  end

  def logout
    session.delete(:user_id)
    session.delete(:cart)
    cookies.delete(:auth_token)
    flash[:success] = "L8r, yo"
    redirect_to "/"
  end
end
