class Api::ExperiencesController < Api::BaseController
  before_filter :require_city
  
  def index
    render :json => @city.upcoming_events.as_json(:api => true)
  end
  
  private
    
  def require_city
    @city = City.find(params[:city_id])
  end
end