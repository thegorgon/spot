class Site::MembershipApplicationsController < Site::BaseController  
  layout 'oreo'
  
  def create
    user_attributes = params[:application].delete(:user_attributes)
    @user = current_user || User.register(user_attributes)
    @application = MembershipApplication.new(params[:application])
    @application.user = @user
    warden.set_user @user if @user && @user.id
    if @application.save
      redirect_to application_path(@application)
    else
      render :action => :new
    end
  end

  def show
    @application = MembershipApplication.find_by_token(params[:id])
    @city = @application.city
  end
  
  def new
  end
  
end