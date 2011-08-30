class Api::EventsController < Api::BaseController
  def create
    if params[:type] == 'acquisition'
      record_user_event(params[:event], params[:value])
    else
      record_acquisition_event(params[:event], params[:value])
    end
    head :ok
  end
end