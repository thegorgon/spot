class Site::ErrorsController < Site::BaseController
  def error_test
    ex = Exception
    ex = ActiveRecord::RecordNotFound if params[:type] == "notfound"
    ex = ActionController::RoutingError if params[:type] == "routing"
    ex = ActionController::UnknownController if params[:type] == "controller"
    ex = ActionController::UnknownAction if params[:type] == "action"
    raise ex
  end
      
  def not_found
    render :template => "/site/errors/404.html.haml", :status => 404
  end
  
  def unprocessable
    render :template => "/site/errors/422.html.haml", :status => 422
  end
  
  def server_error
    render :template => "/site/errors/500.html.haml", :status => 500
  end
end