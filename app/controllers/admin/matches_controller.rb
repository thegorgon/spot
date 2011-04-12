class Admin::MatchesController < Admin::BaseController
  def index
    @source = ExternalPlace.lookup(params[:src])
    @place = Place.find(params[:place_id])
    @matches = PlaceMatch.new(@place, :source => @source, :force => true).matches[@source.to_sym]
  end
  
  def create
    @place = Place.find(params[:place_id])
    @source = ExternalPlace.lookup(params[:match][:source])
    @match = @source.fetch(params[:match][:id])
    existing = @place.external_place(@source.to_sym)
    existing.destroy if existing && existing.source_id != @match.source_id
    @match.bind_to!(@place) if @match.source_id != existing.try(:source_id)
    redirect_to admin_place_path(@place)
  end
end