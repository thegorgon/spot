class Site::PlacesController < Site::BaseController
  layout 'emptysite'
  
  def show
    @place = Place.find(params[:id])
  end
end