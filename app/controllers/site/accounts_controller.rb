class Site::AccountsController < Site::BaseController
  before_filter :require_user, :only => [:show, :destroy, :update]
    
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

  def show
    render :layout => "lightsite"
  end
  
  def update
    current_user.password_account.attributes = params[:password_account] if current_user.password_account
    current_user.attributes = params[:account]
    if (current_user.password_account.nil? || current_user.password_account.save) && current_user.save
      flash[:notice] = "Account Updated!"
      redirect_to account_path
    else
      render :action => "show", :layout => "lightsite"
    end
  end
end