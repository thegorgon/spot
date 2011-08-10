class Biz::BaseController < ApplicationController
  before_filter :require_account
  layout 'biz'
    
  private
    
  def current_account
    current_user.try(:business_account)
  end
  helper_method :current_account
  
  def require_account
    authenticate
    unless current_account
      store_location
      flash[:error] = current_user ? "Tell us about your business." : "Please sign in first."
      url = current_user ? new_biz_account_path : new_session_path
      Rails.logger.info("spot: redirecting from require_account to #{url}"
      redirect_to url
    end
  end

  def require_no_account
    if current_account
      authenticate
      url = biz_account_path
      Rails.logger.info("spot: redirecting from require_no_account to #{url}"
      redirect_to url 
    end
  end
end