class Admin::BaseController < ApplicationController
  layout 'admin'
  USERS = {"pp" => "pilates!"}

  before_filter :authenticate
  
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
  
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "pp" && password == USERS["pp"]
    end
    warden.custom_failure! if performed?
  end  
end