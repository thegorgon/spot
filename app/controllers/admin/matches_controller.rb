class Admin::MatchesController < Admin::BaseController
  def index
    @source = ExternalPlace.lookup(params[:src])
    @place = Place.find(params[:place_id])
    @matches = PlaceMatch.new(@place, @source).potentials[@source.to_sym]
  end
  
  def create
    @place = Place.find(params[:place_id])
    @source = ExternalPlace.lookup(params[:match][:source])
    @match = @source.fetch(params[:match][:id])
    @match.bind_to!(@place)
    redirect_to admin_place_path(@place)
  end
end