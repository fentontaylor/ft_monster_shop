class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :cart, :current_user, :current_admin?, :current_merchant?, :current_merchant_admin?, :current_visitor?

  def cart
    @cart ||= Cart.new(session[:cart] ||= Hash.new(0))
  end

  def current_admin?
    current_user && current_user.admin?
  end

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def current_merchant?
    current_user && (current_user.merchant_employee? || current_user.merchant_admin?)
  end

  def current_merchant_admin?
    current_user && current_user.merchant_admin?
  end

  def visitor_redirect
    render file: 'public/404' unless current_user
  end

  rescue_from ActionController::RoutingError do |exception|
    logger.error 'Routing error occurred'
    render file: 'public/404'
  end
end
