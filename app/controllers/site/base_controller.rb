class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'
  
  before_filter :redirect_to_mobile_if_applicable
    
  protected 
  
  # Stashing Session Data
  def set_invite_request(request)
    session[:invite_request_id] = request.try(:id)
  end
  
  def invite_request
    @invite_request ||= InviteRequest.find_by_id(session[:invite_request_id]) if session[:invite_request_id]
    session[:invite_request_id] = @invite_request.try(:id)
    @invite_request
  end
  helper_method :invite_request
  
  def session_invite
    @session_invite ||= (session[:invite_code] && InvitationCode.find_by_code(session[:invite_code]))
  end
  helper_method :session_invite
  
  def session_promo
    @session_promo ||= (session[:promo_code] && PromoCode.find_by_code(session[:promo_code]))
  end
  helper_method :session_promo
  
  # Authentication
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
      flash[:error] = "Sorry, can you sign in first?"
      redirect_to new_session_path 
    end
  end  
  
  def require_membership
    unless current_user.try(:active_membership)
      flash[:error] = "Sorry, that's for members only."
      application = current_user.membership_application
      redirect_to application ? application_path : new_application_path
    end
  end
  
  def require_no_membership
    if current_user.try(:active_membership)
      flash[:error] = "You're already a member, so you don't really need to go there."
      redirect_to account_path
    end
  end  
end