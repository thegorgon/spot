class Admin::DuplicatesController < Admin::BaseController
  def index
    status = params[:status] || DuplicatePlace::UNRESOLVED
    params[:per_page] = params[:per_page].to_i > 0 ? params[:per_page] : DuplicatePlace.per_page
    @duplicates = DuplicatePlace.where(:status => status).includes(:place_1, :place_2).order('total_distance ASC').paginate(:page => [1, params[:page].to_i].max, :per_page => params[:per_page])
  end
  
  def ignore
    @duplicate = DuplicatePlace.find(params[:id])
    @duplicate.ignore!
    respond_to do |format|
      format.html { redirect_to admin_duplicates_path }
      format.js { render :json => {:html => render_to_string(:partial => "dupe", :object => @duplicate)} }
    end
  end
  
  def resolve
    @duplicate = DuplicatePlace.find(params[:id])
    @canonical = Place.find(params[:canonical_id])
    @duplicate.resolve!(@canonical)
    respond_to do |format|
      format.html { redirect_to admin_duplicates_path }
      format.js { render :json => {:html => render_to_string(:partial => "dupe", :object => @duplicate)} }
    end
  end
end