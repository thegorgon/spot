class Site::PlacesController < Site::BaseController
  layout 'emptysite'
  caches_action :show
  
  def show
    @place = Place.find(params[:id])
    @place = @place.canonical
  end
end