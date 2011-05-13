class Api::UsersController < Api::BaseController
  before_filter :require_user
  before_filter :require_self, :only => [:update]
  
  def show
    render :json => @user
  end
  
  def update
    @user.attributes = params[:user]
    @user.save!
    render :json => @user
  end
  
  private 
  
  def require_user
    @user = User.find(params[:id])
  end

  def require_self
    raise UnauthorizedAccessError unless current_user == @user
  end
end