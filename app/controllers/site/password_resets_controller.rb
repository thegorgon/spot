class Site::PasswordResetsController < Site::BaseController
  before_filter :require_user, :only => [:edit, :update]
  
  def new
  end
  
  def create    
    @account = PasswordAccount.where(:login => params[:reset][:login]).first if params[:reset]
    if @account
      @account.user.reset_perishable_token!
      TransactionMailer.password_reset(@account.user).deliver!
      flash[:notice] = "We just sent instructions to #{@account.login}. Check your email to continue."
      redirect_to new_session_path
    else
      flash[:error] = "We couldn't find any user with that email address. Do you want to <a href='#{new_account_path}'>register</a> instead?"
      redirect_to new_password_reset_path
    end
  end
  
  def edit    
  end
  
  def update
    new_password = params[:reset] && params[:reset][:password]
    @account = PasswordAccount.find_by_user_id(current_user.id)
    @account.password = new_password
    @account.override_current_password!
    if new_password.present? && @account.save
      @account.user.reset_perishable_token!
      flash[:notice] = "We've updated your password. Go ahead and login."
      redirect_to new_session_path
    else
      flash[:error] =  "That's not a great new password. Try something between 4 and 25 characters."
      redirect_to edit_password_reset_path(:token => params[:token])
    end
  end
  
  private
  
  def require_user
    logout
    authenticate
    unless authenticated?
      flash[:error] = "Something went wrong. 
                       Having trouble resetting your password? Try 
                       copying and pasting the url from your email to your browser or
                       <a href='#{new_password_reset_path}'>restarting the process</a>."
      redirect_to root_url
    end
  end
end