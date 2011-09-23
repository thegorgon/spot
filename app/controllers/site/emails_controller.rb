class Site::EmailsController < Site::BaseController
  layout 'oreo'
  
  def show
    @subscription = EmailSubscriptions.fetch_existing(params[:email], params[:key])
    if @subscription.nil?
      flash[:error] = "Sorry, that doesn't look right. Try copying and pasting the link from your email."
      redirect_to root_path
    else
      @bizaccount = BusinessAccount.find_by_email(params[:email]) 
    end
  end
  
  def update
    @subscription = EmailSubscriptions.fetch_existing(params[:email], params[:key])
    @subscription.attributes = params[:email_subscription]
    if @subscription.save
      flash[:notice] = "Notification Settings Successfully Saved!"
    else
      flash[:error] = "Something Went Wrong : #{@subscription.errors.full_messages}"
    end 
    redirect_to email_path(:email => @subscription.email, :key => @subscription.passkey)
  end
  
  def subscribe
    object_params = params[:email_subscription] || {}
    @subscription = EmailSubscriptions.fetch_existing(object_params[:existing], object_params[:passkey])
    @subscription ||= EmailSubscriptions.ensure(object_params)
    @subscription.email = object_params[:email]
    if @subscription.save
      set_partial_application @subscription.application_params
      record_acquisition_event("email acquired")
      if @subscription.city
        flash[:applying] = @subscription.city.subscription_available?
        redirect_to city_path(@subscription.city)
      else
        redirect_to new_city_path
      end
    else
      flash[:error] = "Sorry, that email didn't work. Please try again."
      redirect_to root_path
    end
  end
  
  def mailchimp
    EmailSubscription.mailchimp_hook(params)    
    head :ok
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