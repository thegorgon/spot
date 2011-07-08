class Site::EventsController < Site::BaseController
  layout 'oreo'
  
  def show
    @place = Place.find(params[:place_id])
    @promotion = @place.business.promotion_templates.approved.find(params[:id])
    @date = Date.parse(params[:date]) rescue nil
    @city = City.find_by_id(session[:city_id]) if session[:city_id]
    @event = @promotion.events.on_date(@date) if @date
    @event ||= @promotion.events.upcoming.first
    @subdata = Braintree::TransparentRedirect.create_customer_data(
      :redirect_url => endpoint_subscriptions_url, 
      :customer => {
        :id => current_user.try(:id),
        :custom_fields => {:subscription_plan_id => Subscription::PLAN_ID}
      })
  end
end