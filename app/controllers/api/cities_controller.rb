class Api::CitiesController < Api::BaseController
  skip_before_filter :require_user
  
  def index
    @cities = City.all
    render :json => @cities
  end
end