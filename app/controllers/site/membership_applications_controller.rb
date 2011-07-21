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
        redirect_to application_path
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
    @city ||= City.first
    render :action => "new"
  end
  
  def referred
    @referrer = InvitationCode.valid_code(params[:r])
    if @referrer
      @city = @referrer.user.city
      new
    else
      redirect_to new_application_path
    end
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