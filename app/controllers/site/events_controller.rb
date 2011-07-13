class Site::EventsController < Site::BaseController
  layout 'oreo'
  
  def show
    @place = Place.find(params[:place_id])
    @promotion = @place.business.promotion_templates.approved.find(params[:id])
    @date = Date.parse(params[:date]) rescue nil
    @city = City.find_by_id(session[:city_id]) if session[:city_id]
    @event = @promotion.events.on_date(@date) if @date
    @event ||= @promotion.events.upcoming.first
  end
end