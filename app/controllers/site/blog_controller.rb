class Site::BlogController < Site::BaseController  
  def index
    @posts = Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
    debugger
  end
end