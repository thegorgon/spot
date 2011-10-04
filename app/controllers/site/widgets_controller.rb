class Site::WidgetsController < Site::BaseController
  layout "widgets"

  def show
    @place = Place.find_by_id(params[:pid]) if params[:pid]
  end
  
end