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
end