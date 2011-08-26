class Api::EventsController < Api::BaseController
  def create
    record_user_event(params[:event], params[:value])
    head :ok
  end
end