class Biz::AccountsController < Biz::BaseController
  skip_before_filter :require_account, :except => [:show]
  before_filter :require_no_account, :except => [:show]
  
  def new
    @account = BusinessAccount.new
  end
  
  def create
    @account = BusinessAccount.register(params[:business_account])
    if @account.save
      warden.set_user @account.user
      redirect_to new_biz_business_path
    else
      flash.now[:error] = "Something's not right. Can you double check the fields in red?"
      @page_namespace = "biz_accounts_new"
      render :action => :new
    end
  end
  
  def show
  end
  
  def update
    current_account.attributes = params[:business_account]
    if current_account.save
      redirect_to biz_account_path
    else
      flash[:error] = "Sorry, there were errors with your submission."
      @page_namespace = "biz_accounts_show"
      render :action => "show"
    end
  end
end