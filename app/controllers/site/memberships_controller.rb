class Site::MembershipsController < Site::BaseController
  before_filter :require_user
  before_filter :require_invitation
  before_filter :require_no_membership, :except => [:destroy, :thanks]
  before_filter :require_membership, :only => [:destroy, :thanks]
  layout 'oreo'
  
  def new
    @payment ||= PaymentForm.new(:user => current_user, :plan => params[:plan] || Subscription::PLANS.keys.first)
    @promo_code = (params[:pc] && PromoCode.find_by_code(params[:pc])) || session_promo
    render :action => "new" # allows for just calling "new" from any action
  end
  
  def create
    @payment = PaymentForm.new(:user => current_user, :params => params[:membership])    
    if @payment.try(:save)
      record_acquisition_event("membership")
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
    record_acquisition_event("unsubscribed")
    redirect_to account_path
  end
  
  private
  
  def require_invitation
    unless session_invite
      msg = "Spot is currently available by invitation only. "
      msg << (invite_request.present?? "We're currently processing your invitation" : "You may <a href=\"#{root_path}\">request an invitation.</a>")
      flash[:error] = msg
      redirect_to current_city ? city_path(current_city) : new_city_path
    end
  end
  
end