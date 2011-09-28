class Site::EventsController < Site::BaseController
  before_filter :require_user, :only => [:claim]
  before_filter :require_promotion
  layout 'oreo'
  
  def show
    @date = Date.parse(params[:date]) rescue nil
    @city = City.find_by_id(session[:city_id]) if session[:city_id]
    @event = @promotion.events.on_date(@date).first if @date
    @event ||= @promotion.events.upcoming.first
  end
      
  private
  
  def require_promotion
    @place = Place.find(params[:place_id])
    @promotion = @place.business.promotion_templates.approved.find(params[:id])
  end
end