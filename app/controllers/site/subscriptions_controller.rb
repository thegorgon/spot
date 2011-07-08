class Site::SubscriptionsController < Site::BaseController
  def new
  end
  
  def endpoint
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    @subscription = Subscription.from_redirect(@result) if @result.success?
    if @subscription.try(:save)
      respond_to do |format|
        format.js { }
        format.html {  }
      end
    else
      redirect_to new_subscription_path
    end
  end
end