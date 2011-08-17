class Site::MembershipApplicationsController < Site::BaseController  
  before_filter :require_application, :only => [:show]
  layout 'oreo'
  
  def create
    user_attributes = params[:application].delete(:user_attributes)
    @user = current_user || User.register(user_attributes)
    @application = @user.membership_application
    @application ||= MembershipApplication.new
    @application.attributes = params[:application]
    @application.user = @user
    @user.city = @application.city
    if @user.save
      warden.set_user @user
      if @application.save
        session[:invite_code] = nil # Clear session invite code
        redirect_to @application.approved?? new_membership_path : application_path
      else 
        render :action => :new
      end
    else
      render :action => :new
    end
  end

  def show
    @city = @application.city
  end
  
  def new
    if params[:r]
      @referrer = InvitationCode.valid_code(params[:r] || session[:invite_code])
      @invalid = InvitationCode.expended.find_by_code(params[:r] || session[:invite_code])
    end
    @city = @referrer.user.city if @referrer
    @city ||= City.find_by_id(partial_application[:city_id]) if partial_application[:city_id]
    @city ||= City.subscriptions_available.first
    render :action => "new"
  end
  
  private
  
  def require_application
    @application = current_user.try(:membership_application)
    unless @application
      flash[:notice] = "Please complete your application first."
      redirect_to new_application_path
    end
  end
  
end