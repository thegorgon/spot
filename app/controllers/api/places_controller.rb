class Api::PlacesController < Api::BaseController
  skip_before_filter :require_user
  
  def index
    ids = params[:ids].to_s.split(',')
    @places = Place.where(:id => ids).all.hash_by { |p| p.id.to_s }
    @places = ids.collect { |id| @places[id.to_s] }
    ExternalPlace.add_to(@places)    
    record_user_event("api place load")
    render :json => @places.as_json(:external_places => true)
  end
  
  def search
    @search = PlaceSearch.from_params(params)
    if @search.save
      response.headers["X-Search-ID"] = @search.id.to_s
      record_user_event("api place search")
      render :json => @search.as_json(:external_places => true)
    else
      render :json => []
    end
  end
end