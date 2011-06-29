class Site::CitiesController < Site::BaseController
  def show
    @city = City.find_by_slug(params[:id])
  end
end