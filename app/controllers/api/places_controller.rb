class Api::PlacesController < Api::BaseController
  skip_before_filter :require_user
  
  def index
    ids = params[:ids].split(',')
    @places = Place.where(:id => ids).all.hash_by { |p| p.id.to_s }
    @places = ids.collect { |id| @places[id.to_s] }
    record_user_event("api place load")
    render :json => @places
  end
  
  def search
    @search = PlaceSearch.from_params!(params)
    response.headers["X-Search-ID"] = @search.id.to_s
    record_user_event("api place search")
    render :json => @search
  end
end