class Merchant::BaseController < ApplicationController
  before_action :require_merchant

  private
  
  def require_merchant
    render file: "/public/404" unless current_merchant? || current_admin?
  end

end
