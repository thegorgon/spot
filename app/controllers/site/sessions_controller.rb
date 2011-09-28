class Site::SessionsController < Site::BaseController
  skip_before_filter :require_user, :except => [:destroy]
  layout "oreo"
  
  def new
  end
  
  def create
    authenticate
    if logged_in?
      current_user.invite_request.mark_sent! if session[:invite_code]
      redirect_back_or_default params[:return_to] || root_path
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