class Admin::SearchController < Admin::BaseController
  def new
  end
  
  def show
    @benchmark = Benchmark.measure { @places = Place.search(params[:search]) }
    respond_to do |format|
      format.html
      format.js { render :json => {:html => render_to_string(:partial => "results") }}
    end
  end
end