class Site::BlogController < Site::BaseController  
  # caches_action :index,
  #   :cache_path => Proc.new { |c| [c.send(:blog_index_path), c.send(:locale), AppSetting.get(:blog_revision)].join('/').gsub(/^\//, '') },
  #   :expires_in => 1.week

  def index
    @posts = Wrapr::Tumblr::Item.paginate(:page => params[:page], :per_page => params[:per_page])
  end
end