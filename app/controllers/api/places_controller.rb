class Api::PlacesController < Api::BaseController
  skip_before_filter :require_user
  
  def index
    ids = params[:ids].split(',')
    @places = Place.where(:id => ids).all
    render :json => @places
  end
  
  def search
    @search = PlaceSearch.create!(params.except())
    session[:last_search_id] = response.headers["X-Search-ID"] = @search.id.to_s
    render :json => @search
  end
end