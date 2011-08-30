class Site::CitiesController < Site::BaseController
  before_filter :require_city, :except => :new
  layout 'oreo'
  
  def show
    @city.subscription_available? || @city.has_events? ? calendar : new
  end
  
  def new
    @page_namespace = "site_cities_new"
    render :action => "new"
  end

  def calendar
    @view = "calendar"
    render :action => "calendar"
  end
  
  def experiences
    @view = "experiences"
    render :action => "experiences"
  end
  
  private
  
  def require_city
    @city = City.find_by_slug(params[:id])
    @views = ["calendar", "experiences"]
    raise ActiveRecord::RecordNotFound unless @city
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
  end
end