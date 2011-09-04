class Admin::DuplicatesController < Admin::BaseController
  def index
    status = (params[:status] || DuplicatePlace::UNRESOLVED).to_i
    order = status == DuplicatePlace::UNRESOLVED ? 'total_distance ASC' : 'id DESC'
    @duplicates = DuplicatePlace.where(:status => status).includes(:place_1, :place_2).order(order)
    @duplicates = @duplicates.page([1, params[:page].to_i].max).per(params[:per_page])
  end
  
  def create
    @place1 = Place.find(params[:duplicate][:place_1_id])
    @place2 = Place.find(params[:duplicate][:place_2_id])
    @duplicate = DuplicatePlace.duplicate_for(@place1, @place2)
    @duplicate.resolve!
    redirect_back_or_default(edit_admin_place_path(@place1))
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