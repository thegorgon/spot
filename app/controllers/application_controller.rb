class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :application
  
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
  
  def page_render(options)
    (options[:json] ||= {}).merge!(:page => {:namespace => page_namespace, :controller => controller_name})
    render options
  end
  
  def default_page_render
    page_render :json => {:html => render_to_string(:action => params[:action], :layout => false)}
  end
  
end
