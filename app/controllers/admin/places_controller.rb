class Admin::PlacesController < Admin::BaseController
  before_filter :require_place, :only => [:edit, :update, :destroy, :images]
  respond_to :html
  
  def index
    @places = Place.filter(params)
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