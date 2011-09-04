class Site::PlacesController < Site::BaseController
  def show
    @place = Place.find(params[:id])
    @place = @place.canonical
  end
end