class Api::UsersController < Api::BaseController
  before_filter :require_user
  before_filter :require_self, :only => [:update]
  
  def show
    render :json => @user.as_json(:current_viewer => @user == current_user)
  end
  
  def update
    other_city = params[:user].delete(:other_city) if params[:user]
    @user.email_subscriptions.other_city = other_city if other_city
    @user.attributes = params[:user]
    @user.email_source = 'api' if @user.email_changed?
    @user.save!
    render :json => @user.as_json(:current_viewer => true)
  end
  
  private 
  
  def require_user
    @user = User.find(params[:id])
  end

  def require_self
    raise UnauthorizedAccessError unless current_user == @user
  end
end