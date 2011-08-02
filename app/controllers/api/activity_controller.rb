class Api::ActivityController < Api::BaseController
  skip_before_filter :require_user, :only => :show
   
  def show
    @activity = ActivityItem.feed(params.merge(:device => device_specifications))
    record_user_event("api activity load")
    render :json => @activity
  end
end