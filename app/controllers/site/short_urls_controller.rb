class Site::ShortUrlsController < Site::BaseController
  def show
    @url = ShortUrl.expand(params[:id])
    raise ActiveRecord::RecordNotFound unless @url
    redirect_to @url, :status => 301
  end
end