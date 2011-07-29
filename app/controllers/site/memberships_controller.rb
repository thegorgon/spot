class Site::MembershipsController < Site::BaseController
  before_filter :require_user
  before_filter :require_approved_application
  before_filter :require_no_membership, :except => [:destroy, :thanks]
  before_filter :require_membership, :only => [:destroy, :thanks]
  layout 'oreo'
  
  def new
    @payment ||= PaymentForm.new(:user => current_user, :plan => params[:plan] || Subscription::PLANS.keys.first)
    render :action => "new" # allows for just calling "new" from any action
  end
  
  def create
    @payment = PaymentForm.new(:user => current_user, :params => params)    
    if @payment.try(:save)
      respond_to do |format|
        format.html { redirect_to thanks_membership_path }
      end
    else
      new
    end    
  end
  
  # TR Endoint
  def endpoint
    @result = Braintree::TransparentRedirect.confirm(request.query_string) rescue nil
    @payment = PaymentForm.new(:user => current_user, :tr_result => @result)
    if @payment.try(:save)
      respond_to do |format|
        format.html { redirect_to thanks_membership_path }
      end
    else
      new
    end
  end
  
  def thanks
  end
  
  def destroy
    @membership = current_user.active_membership
    @membership.cancel!
    redirect_to account_path
  end
  
  private
    
  def require_approved_application
    @application = current_user.membership_application
    unless @application.try(:approved?)
      flash[:error] = @application ? 
            "Sorry, your application is still being reviewed." : 
            "Please submit an application first."
      redirect_to @application ? application_path : new_application_path
    end
  end
end