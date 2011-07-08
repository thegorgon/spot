class Site::CitiesController < Site::BaseController
  layout 'oreo'
  
  def show
    @city = City.find_by_slug(params[:id])
    session[:city_id] = @city.id
    @page = CityPage.new(@city)
    @subdata = Braintree::TransparentRedirect.create_customer_data(
      :redirect_url => endpoint_subscriptions_url, 
      :customer => {
        :id => current_user.try(:id),
        :custom_fields => {:subscription_plan_id => Subscription::PLAN_ID}
      })
  end
end