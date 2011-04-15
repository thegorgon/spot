class Api::ActivityController < Api::BaseController
  skip_before_filter :require_user, :only => :show
   
  def show
    @activity = ActivityItem.feed(params)
    record_user_event("api activity load")
    render :json => @activity
  end
end