class Site::EmailsController < Site::BaseController
  def show
    if params[:email]
    else
      redirect_to root_path
    end
  end
  
  def unsubscribe
    BlockedEmail.block!(params[:email], params[:source])
    redirect_to goodbye_email_path
  end
  
  def goodbye
  end
end