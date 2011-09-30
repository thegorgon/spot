class Site::MembershipApplicationsController < Site::BaseController  
  before_filter :require_no_user
  before_filter :require_invite_code, :only => [:create]
  layout 'oreo'
  
  def create
    @account = PasswordAccount.register(params[:password_account], current_user)
    if @account.save
      warden.set_user @account.user
      record_acquisition_event("signup")
      session_invite.claimed!
      if current_city.subscriptions_available?
        set_invite_request nil
        record_acquisition_event("applied")
        redirect_params = {}
        redirect_params[:plan] = params[:plan] if params[:plan]
        redirect_to new_membership_path(redirect_params)
      else
        set_invite_request current_user.invite_request!
        redirect_to city_path(current_user.city)
      end
    else
      render :action => :new
    end
  end

  def new
    set_session_invite(params[:r]) if params[:r]
    if (session_invite && current_user.try(:has_account?))
      session_invite.claimed!
      session[:promo_code] = session_invite.promo_code.code if session_invite.promo_code
      redirect_to new_membership_path
    else
      render :action => "new"
    end
  end
  
  private
  
  def require_invite_code
    set_session_invite(params[:invite_code]) if params[:invite_code]
    unless session_invite
      flash[:error] = "Spot is currently available by invitation only. You may <a href=\"#{root_path}\">request an invitation.</a>"
      redirect_to new_application_path 
    end
  end
  
end