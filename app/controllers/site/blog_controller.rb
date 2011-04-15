class Site::BlogController < Site::BaseController  
  caches_action :index,
    :cache_path => Proc.new { |c| AppSetting.cache_path(:blog, c) },
    :expires_in => 1.week

  def index
    @posts = Wrapr::Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
  end
end