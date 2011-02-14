class Admin::SearchController < Admin::BaseController
  def new
    @places = []
  end
  
  def show
    @places = Place.search(params[:search])
    respond_to do |format|
      format.html
      format.js { render :json => {:html => render_to_string(:partial => "/admin/places/table", :object => @places, :as => :places) }}
    end
  end
end