class Admin::SearchController < Admin::BaseController
  def new
    @search = PlaceSearch.new(params)
  end
  
  def show
    @search = PlaceSearch.new(params)
    respond_to do |format|
      format.html
      format.js { render :json => {:html => render_to_string(:partial => "results") }}
    end
  end  
end