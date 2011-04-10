class Site::BaseController < ApplicationController
  layout 'site'
  helper 'site'

  rescue_from Exception, :with => :render_error
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  
  protected
  
  def render_error(exception=nil)
    render :template => "/site/errors/500.html.haml", :status => 500
  end
    
  def default_render(*args)
    respond_to do |format|
      format.html { render(*args) }
      format.js do 
        options = args.extract_options!
        (options[:json] ||= {}).merge!(:page => {:namespace => page_namespace, :controller => controller_name})
        options[:json][:html] ||= render_to_string(:action => params[:action])
        args << options
        render(*args)
      end
    end
  end
      
  def redirect_to(*args)
    respond_to do |format|
      format.html { super(*args) }
      format.js { js_redirect_to(*args)}
    end
  end
  
  def require_user
    authenticate
    unless logged_in?
      store_location
      flash[:error] = "Sorry, can you login first?"
      redirect_to new_session_path 
    end
  end  
end