class Admin::SearchController < Admin::BaseController
  def new
    @search = PlaceSearch.from_params(params)
  end
  
  def show
    @search = PlaceSearch.from_params(params)
    respond_to do |format|
      format.html
      format.js { render :json => { :html => render_to_string(:partial => "results") }}
    end
  end  
end