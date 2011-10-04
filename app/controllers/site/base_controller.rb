class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'
  
  before_filter :redirect_to_mobile_if_applicable
  before_filter :stash_session_params
  
  protected 
  
  #Stashing city
  def current_city
    unless @city
      city_id = current_user.try(:city_id) || invite_request.try(:city_id) || session[:city_id] 
      @city = City.find_by_id(city_id)
    end
    @city
  end
  helper_method :current_city
  
  def update_users_city_to_current
    current_user.update_attribute(:city_id, current_city.id) if current_user && current_city && current_user.city_id != current_city.id
  end
  
  # Stashing Session Data
  def stash_session_params
    if params[:mc]
      set_session_invite params[:mc]
      set_session_promo params[:mc]
    end
    
    if params[:ir] && ir = InviteRequest.find_by_id(params[:ir])
      set_invite_request(ir)
    end
    
    if params[:asrc].present?
      source = AcquisitionSource.find_by_id(params[:asrc])
      source_id = source.try(:id)
      session[:original_acquisition_source_id] ||= source_id # or equal, only set if not yet set
      session[:acquisition_source_id] = source_id # resets, always store
      source.clicked!(current_user)
      record_acquisition_event("click")
    end
  end
  
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
    session[:invalid_invite] = false
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
    session_invite.nil? && session[:invalid_invite]
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
    unless current_member?
      flash[:error] = "Sorry, that's for members only."
      redirect_to current_user.try(:ready_for_membership?) ? new_membership_path : new_application_path
    end
  end
  
  def require_no_membership
    if current_member?
      flash[:error] = "You're already a member, so you don't really need to go there."
      redirect_to account_path
    end
  end  
end