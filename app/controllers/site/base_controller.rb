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
  
  def require_membership
    unless current_user.try(:active_membership)
      flash[:error] = "Sorry, that's for members only."
      application = current_user.membership_application
      redirect_to application ? application_path(application) : new_application_path
    end
  end
  
  def require_no_membership
    if current_user.try(:active_membership)
      flash[:error] = "You're already a member, so you don't really need to go there."
      redirect_to account_path
    end
  end
end