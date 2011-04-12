class Site::SitemapsController < Site::BaseController
  caches_page :show

  def show
    @places = Place.order("id DESC").limit(10000).all
    render :layout => false
  end
end