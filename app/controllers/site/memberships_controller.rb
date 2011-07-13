class Site::MembershipsController < Site::BaseController
  before_filter :require_user
  before_filter :require_approved_application
  layout 'oreo'
  
  def new
    @trdata = Braintree::TransparentRedirect.create_customer_data(
      :redirect_url => endpoint_membership_url, 
      :customer => {
        :id => "customer_#{current_user.id}",
        :email => current_user.email
      }
    )  
    render :action => "new" # allows for just calling "new" from any action
  end
  
  def create
  end
  
  # TR Endoint
  def endpoint
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    @membership = Membership.register(current_user, @result)
    if @membership.try(:save)
      respond_to do |format|
        format.html do
          flash[:notice] = "Payment Accepted! Now go forth, and explore!"
          redirect_to city_path(@membership.city)
        end
      end
    else
      flash.now[:error] = @membership.try(:errors).try(:full_messages).try(:join)
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