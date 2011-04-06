class Site::PlacesController < Site::BaseController
  def show
    redirect_to getspot_path
  end
end