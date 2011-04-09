class Site::PlacesController < Site::BaseController
  layout 'emptysite'
  
  def show
    @place = Place.find_by_id(params[:id])
    @place = @place.canonical
  end
end