class Admin::PlacesController < Admin::BaseController
  before_filter :require_place, :only => [:edit, :update, :destroy, :images, :dedupe]
  respond_to :html
  
  def index
    @places = Place.filter(params)
    respond_with(@places)
  end
  
  def search
    params[:per_page] ||= 10 if request.xhr?
    @places = Place.search(params[:term], :star => true, :match_mode => :any, :page => params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.js { render :json => @places }
      format.html
    end
  end
  
  def matches
    @places = Place.filter(params)
    @externals = ExternalPlace.associated_with(@places.collect { |p| p.id })
  end
  
  def new
    @place = Place.new
    respond_with(@place)
  end

  def dedupe
    flash[:notice] = "Deduping #{@place.name}"
    Resque.enqueue(Jobs::PlaceDeduper, @place.id)
    redirect_to edit_admin_place_path(@place)
  end

  def create
    @place = Place.new(params[:place])
    success = @place.save
    respond_to do |format|
      format.html { redirect_to admin_place_path(@place) }
      format.js { render :json => @place }
    end
  end
  
  def show
    redirect_to edit_admin_place_path(params[:id])
  end
  
  def edit
  end
  
  def update
    @place.attributes = params[:place]
    success = @place.save
    respond_to do |format|
      format.html do 
        if success
          flash[:notice] = "#{@place.name} Updated!"
          redirect_to(edit_admin_place_path(@place))
        else
          flash.now[:error] =  "There were errors with your submission"
          render(:action => "edit")
        end
      end
      format.js { render :json => @place.as_json(:default_images => true, :processed_images => true) }
    end
  end
  
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to admin_places_path }
    end
  end
  
  def images
    @search = ImageSearch.new(@place, request)
    @images = @search.results
    respond_to do |format|
      format.js { render :json => { :html => render_to_string(:partial => "images") } }
    end
  end
  
  private
  
  def require_place
    @place = Place.find(params[:id])
  end
end