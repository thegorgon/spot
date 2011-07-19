class Site::MembershipApplicationsController < Site::BaseController  
  before_filter :require_application, :only => [:show]
  layout 'oreo'
  
  def create
    user_attributes = params[:application].delete(:user_attributes)
    @user = current_user || User.register(user_attributes)
    @application = MembershipApplication.new(params[:application])
    @application.user = @user
    @user.city = @application.city
    warden.set_user @user if @user && @user.id
    if @application.save && @user.save
      redirect_to application_path
    else
      render :action => :new
    end
  end

  def show
    @city = @application.city
  end
  
  def new
    @city ||= City.first
    render :action => "new"
  end
  
  def referred
    @referrer = MembershipApplication.find_by_token(params[:rid])
    @city = @referrer.city
    new
  end
  
  private
  
  def require_application
    @application = current_user.membership_application
    unless @application
      flash[:notice] = "Please complete your application first."
      redirect_to new_application_path
    end
  end
  
end