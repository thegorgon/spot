class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'
  
  protected
    
  def require_no_user
    authenticate
    if logged_in?
      store_location
      flash[:error] = "Sorry, that's for new users only."
      redirect_to account_path 
    end
  end  

  def require_user
    authenticate
    unless logged_in?
      store_location
      flash[:error] = "Sorry, can you login first?"
      redirect_to new_session_path 
    end
  end  
end