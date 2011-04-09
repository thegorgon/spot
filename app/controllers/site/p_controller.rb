class Site::PController < Site::BaseController
  def show
    @place = Place.find(params[:id])
    redirect_to place_path(@place)
  end
end