class Site::BlogController < Site::BaseController  
  def index
    @posts = Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.html 
      format.js { default_page_render }
    end
  end
end