class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'
  
  before_filter :redirect_to_mobile_if_applicable
    
  protected 
  
  #Mobile App Transfers
  def in_mobile_app!
    session[:in_mobile_app] = 1
  end
  
  def left_mobile_app!
    session[:in_mobile_app] = nil
  end
  
  def in_mobile_app?
    session[:in_mobile_app]
  end
  
  #Stashing city
  def current_city
    unless @city
      city_id = current_user.try(:city_id) || invite_request.try(:city_id) || session[:city_id] 
      @city = City.find_by_id(city_id)
    end
    @city
  end
  helper_method :current_city
  
  # Stashing Session Data
  def set_invite_request(request)
    session[:invite_request_id] = request.try(:id)
  end
  
  def invite_request
    @invite_request ||= current_user.try(:invite_request!)
    @invite_request ||= InviteRequest.find_by_id(session[:invite_request_id]) if session[:invite_request_id]
    session[:invite_request_id] = @invite_request.try(:id)
    @invite_request
  end
  helper_method :invite_request
  
  def set_session_invite(code)
    @session_invite = InvitationCode.valid_code(code)
    session[:invite_code] = @session_invite.try(:code)
    session[:invalid_invite] = true if code && @session_invite.nil?
    set_session_promo(code) if @session_invite
    @session_invite
  end
  
  def set_session_promo(code)
    @session_promo = PromoCode.valid_code(code)
    session[:promo_code] = @session_promo.try(:code)
    @session_promo
  end
  
  def session_invite
    @session_invite ||= (session[:invite_code] && InvitationCode.valid_code(session[:invite_code]))
    @session_invite ||= invite_request.invite if invite_request.try(:invite_sent?)
    @session_invite
  end
  helper_method :session_invite
    
  def session_promo
    @session_promo ||= (session[:promo_code] && PromoCode.valid_code(session[:promo_code]))
  end
  helper_method :session_promo
  
  def invalid_invite?
    session[:invalid_invite]
  end
  helper_method :invalid_invite?
  
  # Authentication
  def require_no_user
    authenticate
    if logged_in? && current_user.has_account?
      store_location
      flash[:error] = "Sorry, that's for new users only. You need to <a href=\"#{logout_path}\">logout</a> first."
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