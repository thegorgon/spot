class Site::ShortUrlsController < Site::BaseController
  def show
    redirect_to ShortUrl.expand(params[:id]), :status => 301
  end
end