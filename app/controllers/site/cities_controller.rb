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
    @launch_apply = invite_request.try(:invite_sent?)
    render :action => "calendar"
  end
  
  def experiences
    @view = "experiences"
    @launch_apply = invite_request.try(:invite_sent?)
    render :action => "experiences"
  end
  
  def redirect
    @city = City.find_by_id(params[:id])
    redirect_to @city ? city_path(@city) : new_city_path
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