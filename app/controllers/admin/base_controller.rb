class Admin::BaseController < ApplicationController
  layout 'admin'
  USERS = {"pp" => "pilates!"}

  before_filter :require_user
  
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
    unless current_user && current_user.admin?
      store_location
      flash[:error] = "Sorry, that's for Spot administrators only."
      redirect_to root_path
    end
  end  
end