class Api::ActivityController < Api::BaseController
  skip_before_filter :require_user, :only => :show
   
  def show
    @activity = ActivityItem.feed(params)
    render :json => @activity
  end
end