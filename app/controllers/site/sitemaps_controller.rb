class Site::SitemapsController < Site::BaseController
  caches_action :show,
    :cache_path => Proc.new { |c| AppSetting.cache_path(:sitemap, c) },  
    :expires_in => 1.week
  
  def show
    @places = Place.order("id DESC").limit(1000).all
    render :layout => false
  end
end