class Site::AccountsController < Site::BaseController
  before_filter :require_user, :only => [:destroy]
    
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
end