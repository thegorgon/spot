class Admin::PlacesController < Admin::BaseController
  respond_to :html
  
  def index
    @places = Place.paginate(:page => params[:page], :per_page => params[:per_page])
    respond_with(@places)
  end
  
  def new
    @place = Place.new
    respond_with(@place)
  end

  def create
    @place = Place.new(params[:place])
    @place.save
    respond_with(@place)
  end
end