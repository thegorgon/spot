class Site::CitiesController < Site::BaseController
  before_filter :require_city, :except => :new
  layout 'oreo'
  
  def show
    new unless @city.subscription_available?
  end
  
  def new
    @page_namespace = "site_cities_new"
    render :action => "new"
  end

  def calendar
  end
  
  private
  
  def require_city
    @city = City.find_by_slug(params[:id])
    raise ActiveRecord::RecordNotFound unless @city
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
  end
end