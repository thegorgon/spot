class Site::ErrorsController < Site::BaseController
  def error_test
    ex = Exception.new
    ex = ActiveRecord::RecordNotFound.new if params[:type] == "notfound"
    ex = ActionController::RoutingError.new("message") if params[:type] == "routing"
    ex = ActionController::UnknownController.new if params[:type] == "controller"
    ex = ActionController::UnknownAction.new if params[:type] == "action"
    raise ex
  end
      
  def not_found
    render :template => "/site/errors/404.html.haml", :status => 404, :layout => "site"
  end
  
  def unprocessable
    render :template => "/site/errors/422.html.haml", :status => 422, :layout => "site"
  end
  
  def server_error
    render :template => "/site/errors/500.html.haml", :status => 500, :layout => "site"
  end
end