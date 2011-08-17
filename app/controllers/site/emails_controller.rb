class Site::EmailsController < Site::BaseController
  def show
    redirect_to root_path unless params[:email]
  end
  
  def subscribe
    @subscription = EmailSubscriptions.ensure(params[:email_subscription])
    if @subscription.save
      set_partial_application @subscription.attributes.slice("email", "first_name", "last_name", "city_id")
      if @subscription.city
        flash[:applying] = @subscription.city.subscription_available?
        redirect_to city_path(@subscription.city)
      else
        # TODO Figure out what to do here?
        redirect_to new_city_path
      end
    else
      redirect_to root_path
    end
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