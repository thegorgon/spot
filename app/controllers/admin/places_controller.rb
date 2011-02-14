class Admin::PlacesController < Admin::BaseController
  before_filter :require_place, :only => [:edit, :update, :destroy, :images]
  respond_to :html
  
  def index
    @finder = Place.filter(params)
    @places = @finder.paginate(:page => params[:page], :per_page => params[:per_page])
    respond_with(@places)
  end
  
  def new
    @place = Place.new
    respond_with(@place)
  end

  def create
    @place = Place.new(params[:place])
    success = @place.save
    respond_to do |format|
      format.html { redirect_to admin_places_path(@place) }
      format.js { render :json => @place }
    end
  end
  
  def edit
  end
  
  def update
    @place.attributes = params[:place]
    success = @place.save
    if success
      flash[:notice] = "#{@place.name} Updated!"
    else
      flash.now[:error] =  "There were errors with your submission"
    end
    respond_to do |format|
      format.html { success ? redirect_to(edit_admin_place_path(@place)) : render(:action => "edit") }
      format.js { render :json => @place }
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