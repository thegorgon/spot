class Site::MembershipsController < Site::BaseController
  before_filter :require_user
  before_filter :require_approved_application
  before_filter :require_no_membership, :except => :destroy
  before_filter :require_membership, :only => :destroy
  layout 'oreo'
  
  def new
    @payment ||= PaymentForm.new(:user => current_user)
    render :action => "new" # allows for just calling "new" from any action
  end
  
  def create
  end
  
  # TR Endoint
  def endpoint
    @result = Braintree::TransparentRedirect.confirm(request.query_string) rescue nil
    @payment = PaymentForm.new(:user => current_user, :tr_result => @result)
    if @payment.try(:save)
      respond_to do |format|
        format.html do
          flash[:notice] = "Payment Accepted! Now go forth, and explore!"
          redirect_to city_path(@payment.city)
        end
      end
    else
      new
    end
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
      redirect_to @application ? application_path(@application) : new_application_path
    end
  end
end