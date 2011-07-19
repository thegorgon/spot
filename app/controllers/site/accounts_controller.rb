class Site::AccountsController < Site::BaseController
  before_filter :require_no_user, :only => [:new]
  before_filter :require_user, :only => [:show, :destroy, :update]
  layout "oreo"

  def new
    @nonce = Nonce.new(:session => session)
  end
    
  def create
    @account = PasswordAccount.register(params[:password_account])
    @nonce = Nonce.new(:session => session)
    if @account.save
      warden.set_user @account.user
      redirect_back_or_default root_path
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
      redirect_to account_path
    else
      render :action => "show"
    end
  end
end