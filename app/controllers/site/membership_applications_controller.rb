class Site::MembershipApplicationsController < Site::BaseController  
  before_filter :require_invite_code, :only => [:create]
  layout 'oreo'
  
  def create
    @account = PasswordAccount.register(params[:password_account])
    if @account.save
      warden.set_user @account.user
      record_acquisition_event("signup")
      @invite_code.claimed!
      session[:invite_code] = @invite_code
      session[:promo_code] = @invite_code.promo_code.code if @invite_code.promo_code
      if current_city.subscriptions_available?
        set_invite_request nil
        record_acquisition_event("applied")
        redirect_to new_membership_path
      else
        set_invite_request current_user.invite_request!
        redirect_to city_path(current_user.city)
      end
    else
      render :action => :new
    end
  end

  def new
    session[:invite_code] = param_code.code if params[:r] && param_code = InvitationCode.valid_code(params[:r])
    @referrer = InvitationCode.valid_code(session[:invite_code])
    @invalid = InvitationCode.expended.find_by_code(session[:invite_code]) if @referrer.nil?
    @referrer ||= invite_request.invite if invite_request.try(:invite_sent?)
    if (@referrer && current_user)
      @referrer.try(:claimed!)
      session[:promo_code] = @referrer.promo_code.code if @referrer.promo_code
      redirect_to new_membership_path
    else
      render :action => "new"
    end
  end
  
  private
  
  def require_invite_code
    code = params[:invite_code] || session[:invite_code]
    @invite_code = InvitationCode.valid_code(code)
    unless @invite_code
      flash[:error] = "Spot is currently available by invitation only. You may <a href=\"#{root_path}\">request an invitation.</a>"
      redirect_to new_application_path 
    end
  end
  
end