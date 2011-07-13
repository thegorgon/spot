class Site::CitiesController < Site::BaseController
  layout 'oreo'
  
  def show
    @city = City.find_by_slug(params[:id])
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
  end
end