class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'
  
  protected
    
  def require_user
    authenticate
    unless logged_in?
      store_location
      flash[:error] = "Sorry, can you login first?"
      redirect_to new_session_path 
    end
  end  
end