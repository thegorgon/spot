class Site::ErrorsController < Site::BaseController      
  layout 'site'
  
  def not_found
    render :template => "/site/errors/404.html.haml", :status => 404
  end
  
  def unprocessable
    render :template => "/site/errors/422.html.haml", :status => 422
  end
  
  def server_error
    render :template => "/site/errors/500.html.haml", :status => 500
  end
  
  def upgrade
    render :template => "/site/errors/upgrade.html.haml", :status => 200
  end
end