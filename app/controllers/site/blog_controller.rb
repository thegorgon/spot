class Site::BlogController < Site::BaseController  
  def index
    @posts = Wrapr::Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
  end
end