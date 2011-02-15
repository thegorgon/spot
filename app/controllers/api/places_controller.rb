class Api::PlacesController < Api::BaseController
  skip_before_filter :require_user
  
  def index
    ids = JSON.parse(params[:ids])
    @places = Place.where(:id => ids).all
    render :json => @places
  end
  
  def search
    render :json => PlaceSearch.perform(params)
  end
end