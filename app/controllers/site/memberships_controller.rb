class Site::MembershipsController < Site::BaseController
  layout 'oreo'
  before_filter :require_user
  before_filter :update_users_city_to_current, :only => [:new]
  before_filter :require_user_preparations, :only => [:new, :create]
  before_filter :require_no_membership, :except => [:destroy, :show, :thanks]
  before_filter :require_membership, :only => [:destroy, :show, :thanks]
  
  def new
    @payment ||= PaymentForm.new(:user => current_user, :plan => params[:plan] || Subscription::PLANS.keys.first)
    @promo_code = (params[:pc] && PromoCode.find_by_code(params[:pc])) || session_promo
    render :action => "new" # allows for just calling "new" from any action
  end
  
  def create
    @payment = PaymentForm.new(:user => current_user, :params => params[:membership])    
    if @payment.try(:save)
      track_signup!
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
      track_signup!
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
  
  def require_user_preparations
    unless current_user.try(:ready_for_membership?)
      flash[:notice] = "First we need to know a little bit more about you."
      redirect_to new_application_path      
    end
  end
  
  def track_signup!
    record_acquisition_event("membership")
    session_invite.try(:signup!)
    set_session_invite nil
  end
end