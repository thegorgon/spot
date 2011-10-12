class Site::CitiesController < Site::BaseController
  layout 'oreo'
  before_filter :require_city, :except => [:new, :redirect]
  
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
  
  def perks
    @view = "perks"
    render :action => "perks"
  end
  
  def redirect
    @city = City.find_by_id(params[:id])
    redirect_to @city ? city_path(@city) : new_city_path
  end
  
  private
  
  def require_city
    @city = City.find_by_slug(params[:id])
    @city ||= invite_request.try(:city)
    @views = ["calendar", "perks"]
    @launch_explain = invite_request.try(:invite_sent?)
    raise ActiveRecord::RecordNotFound unless @city
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
  end
end