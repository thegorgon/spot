class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :application, :place
  
  private
  
  # Return the rendered page namespace, derived from the Controller name and rendered template. This identifier
  # can be used as a CSS class/id name and JavaScript variable name.  
  def page_namespace
    @page_namespace ||= "#{controller_name}_#{action_name}"
  end
  helper_method :page_namespace
  
  def controller_name
    name = params[:controller].tr('/','_')
    return name
  end
  helper_method :controller_name
    
  def js_redirect_to(*args)
    render :json => {:redirect_to => url_for(*args)}
  end
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
