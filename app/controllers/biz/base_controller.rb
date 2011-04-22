class Biz::BaseController < ApplicationController
  before_filter :require_admin, :if => Proc.new { Rails.env.production? }
  before_filter :require_account
  
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
  
  def current_account
    current_user.try(:business_account)
  end
  helper_method :current_account
  
  def require_account
    authenticate
    unless current_account
      store_location
      flash[:error] = current_user ? "Tell us about your business." : "Please login first."
      url = current_user ? new_biz_account_path : new_session_path
      Rails.logger.info "spot-app: redirecting from require_account to #{url}"
      redirect_to url
    end
  end

  def require_no_account
    if current_account
      authenticate
      url = biz_account_path
      Rails.logger.info "spot-app: redirecting from require_no_account to #{url}"
      redirect_to url 
    end
  end
end