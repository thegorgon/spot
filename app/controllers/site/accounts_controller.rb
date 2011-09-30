class Site::AccountsController < Site::BaseController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :destroy, :update]
  layout "oreo"

  def new
  end
    
  def create
    authenticate
    @account = PasswordAccount.register(params[:password_account], current_user)
    if @account.save
      warden.set_user @account.user
      @account.user.invite_request.mark_sent! if session_invite
      record_acquisition_event("signup")
      if in_mobile_app?
        redirect_to to_mobile_app_path
      else
        redirect_back_or_default root_path
      end
    else
      flash.now[:error] = "Something's not right. Can you double check the fields in red?"
      render :action => :new
    end
  end  
  
  def endpoint
    @result = Braintree::TransparentRedirect.confirm(request.query_string) rescue nil
    @card = CreditCard.find_by_token(@result.try(:success?)? @result.credit_card.token : @result.params[:payment_method_token])
    @card.tr_update_result = @result
    if @card.try(:save)
      flash[:notice] = "Credit Card Updated!"
      redirect_to account_path
    else
      show
    end
  end
  
  def show
    @page_namespace = "site_accounts_show"
    render :action => "show"
  end
  
  def update
    current_user.password_account.attributes = params[:password_account] if current_user.password_account
    current_user.attributes = params[:account]
    if (current_user.password_account.nil? || current_user.password_account.save) && current_user.save
      flash[:notice] = "Account Updated!"
      redirect_to params[:redirect_to] || account_path
    else
      render :action => "show"
    end
  end
end