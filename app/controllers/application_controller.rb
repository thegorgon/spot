class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :localize
  helper :application, :place
  
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActionController::UnknownController, :with => :render_404
  rescue_from ActionController::UnknownAction, :with => :render_404
  
  private  
  
  def render_404(exception=nil)
    render :template => "/site/errors/404.html.haml", :status => 404
  end
  
  def require_admin
    authenticate
    unless current_user && current_user.admin?
      store_location
      flash[:error] = "Sorry, that's for Spot administrators only. <a href=\"#{new_session_path}\">Login?</a>"
      redirect_to root_path
    end
  end  

  def with_flash_maintenance
    old_flash = flash
    yield
    flash = old_flash
  end
  
  def logged_in?
    authenticated? && (warden.winning_strategy.nil? || warden.winning_strategy.store?)
  end
  helper_method :logged_in?
  
  def geo_ip
    @geo_ip ||= GeoIP.new('db/GeoIP.dat')
  end
  
  def geo_country
    geo_ip.country(request.remote_ip)
  end
  helper_method :geo_country
  
  def country_code
    geo_country.country_code2
  end
  helper_method :country_code
  
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
    session[:return_to] = request.fullpath
  end
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def request_language
    request.user_preferred_languages.first.split('-', 2).first rescue "en"
  end
  
  def ip_location
    "#{request_language}-#{country_code}" if country_code.present? && country_code != "--"
  end
  helper_method :ip_location
  
  def request_location
    ip_location || request.user_preferred_languages.first
  end
  helper_method :request_location
  
  def localize
    I18n.locale = current_user.try(:locale) || request.compatible_language_from(I18n.available_locales) || I18n.default_locale
    if logged_in?
      attributes = {}
      attributes[:locale] = I18n.locale if current_user.locale.nil?
      attributes[:location] = request_location if current_user.location != request_location
      current_user.update_attributes(attributes) if logged_in? && attributes.present?
    end
  end  
end
