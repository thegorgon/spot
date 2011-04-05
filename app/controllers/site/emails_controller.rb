class Site::EmailsController < Site::BaseController
  def show
    redirect_to root_path unless params[:email]
  end
  
  def unsubscribe
    BlockedEmail.block!(params[:email])
    redirect_to goodbye_email_path
  end
  
  def goodbye
  end
  
  def availability
    exists = PasswordAccount.where(:login => params[:value]).exists?
    json = {:valid => !exists}
    json[:message] = "exists" unless json[:valid]
    render :json => json
  end
  
  def existence
    exists = PasswordAccount.where(:login => params[:value]).exists?
    json = {:valid => exists}
    json[:message] = "address unknown" unless json[:valid]
    render :json => json
  end
end