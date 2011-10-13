class Site::MembershipApplicationsController < Site::BaseController  
  layout 'oreo'
  before_filter :require_no_user, :only => [:create]
  before_filter :require_user, :only => [:update]
  before_filter :update_users_city_to_current, :only => [:new]
  
  def create
    @account = PasswordAccount.register(params[:password_account], current_user)
    if @account.save
      warden.set_user @account.user
      move_forward!
    else
      flash.now[:error] = "Sorry, there were errors with your submission"
      render :action => :new
    end
  end
  
  def update
    current_user.attributes = params[:password_account].delete(:user_attributes)
    current_user.first_name = params[:password_account][:first_name]
    current_user.last_name = params[:password_account][:last_name]
    current_user.email = params[:password_account][:login]
    
    if current_user.save
      move_forward!
    else
      flash.now[:error] = "Sorry, there were errors with your submission"
      render :action => :new
    end
  end

  def new
    set_session_invite(params[:r]) if params[:r]
    if (session_invite && current_user.try(:ready_for_membership?))
      session_invite.claimed!
      session[:promo_code] = session_invite.promo_code.code if session_invite.promo_code
      redirect_to new_membership_path
    else
      render :action => "new"
    end
  end
  
  private
    
  def move_forward!
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
  end
    
end