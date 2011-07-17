class Site::CitiesController < Site::BaseController
  layout 'oreo'
  
  def show
    @city = City.find_by_slug(params[:id])
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
    new unless @city.subscription_available?
  end
  
  def new
    @page_namespace = "site_cities_new"
    render :action => "new"
  end
end