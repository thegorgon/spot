class Biz::BaseController < ApplicationController
  before_filter :require_admin
  
  layout 'biz'
  
  private
  
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
  
  def biz_account
    current_user.try(:biz_account)
  end
  helper_method :biz_account
  
  def require_biz_account
    authenticate
    unless biz_account
      store_location
      flash[:error] = current_user ? "Tell us about your business." : "Please login first."
      redirect_to current_user ? new_business_path : new_session_path
    end
  end
end