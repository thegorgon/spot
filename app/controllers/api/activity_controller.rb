class Api::ActivityController < Api::BaseController
  def show
    @activity = ActivityItem.feed(params)
    render :json => @activity
  end
end