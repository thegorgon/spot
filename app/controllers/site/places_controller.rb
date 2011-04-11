class Site::PlacesController < Site::BaseController
  layout 'emptysite'
  caches_page :show
  
  def show
    @place = Place.find(params[:id])
    @place = @place.canonical
  end
end