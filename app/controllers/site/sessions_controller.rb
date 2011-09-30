class Site::SessionsController < Site::BaseController
  skip_before_filter :require_user, :except => [:destroy]
  before_filter :require_no_user, :only => [:new, :create]
  layout "oreo"
  
  def new
    @logged_in_user = current_user
    with_flash_maintenance { logout } if @logged_in_user      
  end
    
  def create
    authenticate
    if logged_in?
      current_user.invite_request.mark_sent! if session_invite
      if in_mobile_app?
        redirect_to to_mobile_app_path
      else
        redirect_back_or_default params[:return_to] || root_path
      end
    else
      flash[:error] = "We couldn't log you in. Please try again."
      redirect_to new_session_path
    end
  end
  
  def destroy
    logout
    redirect_back_or_default params[:return_to] || root_path
  end
end