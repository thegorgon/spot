class Admin::PlacesController < Admin::BaseController
  respond_to :html
  
  def index
    @finder = Place.order('id DESC')
    @places = @finder.paginate(:page => params[:page], :per_page => params[:per_page])
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
  
  def edit
    @place = Place.find_by_id(params[:id])
  end
  
  def update
    @place = Place.find_by_id(params[:id])
    @place.attributes = params[:place]
    success = @place.save
    respond_to do |format|
      format.js { render :json => { :html => {:row => render_to_string(:partial => "place_row", :object => @place, :as => :place) } } }
    end
  end
  
  def images
    @place = Place.find_by_id(params[:id])
    @search = ImageSearch.new(@place, request)
    @images = @search.results
    respond_to do |format|
      format.js { render :json => { :html => render_to_string(:partial => "images") } }
    end
  end
end