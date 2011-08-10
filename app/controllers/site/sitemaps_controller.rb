class Site::SitemapsController < Site::BaseController
  caches_action :show,
    :cache_path => Proc.new { |c| AppSetting.cache_path(:sitemap, c) },  
    :expires_in => 1.week
  
  def show
    @promotions = PromotionTemplate.approved.includes(:business => :place).all
    @cities = City.visible.all
    @blog_entries = BlogPost.filter(:per_page => 1000)
    
    render :layout => false
  end
end