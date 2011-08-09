class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :stash_controller
  before_filter :localize
  helper :application, :place
  
  rescue_from Exception, :with => :render_error
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActionController::UnknownController, :with => :render_404
  rescue_from ActionController::UnknownAction, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  
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

  def nonce
    @nonce ||= Nonce.new(:session => session)
  end
  helper_method :nonce

  def mobile_browser?
    iphone_browser? || android_browser?
  end
  helper_method :mobile_browser?

  def iphone_browser?
    !!(request.user_agent.to_s.downcase =~ /iphone/)
  end
  helper_method :iphone_browser?
  
  def android_browser?
    !!(request.user_agent.to_s.downcase =~ /android/)
  end
  helper_method :android_browser?

  def log_error(exception)
    message = "\n#{exception.class} (#{exception.message}):\n"
    message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
    message << "  " << clean_backtrace(exception, :silent).join("\n  ")
    Rails.logger.fatal("#{message}\n\n") if Rails.logger
    notify_hoptoad(exception) if exception.notifiable?
  end

  def render_error(exception)
    handle_error(exception)
    render :template => "/site/errors/500.html.haml", :status => 500, :layout => "site"
  end
    
  def clean_backtrace(exception, *args)
    Rails.backtrace_cleaner.clean(exception.backtrace, *args)
  end
  
  def render_404(exception=nil)
    handle_error(exception)
    render :template => "/site/errors/404.html.haml", :status => 404, :layout => "site"
  end
  
  def handle_error(exception=nil)
    log_error(exception)
    @exception = exception
    @controller_name = "site_errors"
    @module_names = "site site_errors"
    @page_namespace = "site_errors_show"
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
    return_to = session[:return_to]
    yield
    flash = old_flash
    session[:return_to] = return_to
  end
  
  def logged_in?
    authenticated? && (warden.winning_strategy.nil? || warden.winning_strategy.store?)
  end
  helper_method :logged_in?
  
  def geo_ip
    @geo_ip ||= GeoIP.new('db/GeoIP.dat')
  end
  
  def request_ip
    if Rails.env.development? && params[:ip]
      params[:ip]
    else
      request.remote_ip
    end 
  end
  
  def geo_country
    geo_ip.country(request_ip)
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
    @controller_name ||= params[:controller].tr('/','_')
  end
  helper_method :controller_name

  def module_names
    @module_names ||= params[:controller].split('/').reverse.drop(1).join(" ")
  end
  helper_method :module_names
    
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
    request.user_preferred_languages.first.split(/[-_\s]/, 2).first rescue "en"
  end
  
  def ip_location
    country_code if country_code.present? && country_code != "--"
  end
  helper_method :ip_location
  
  def request_location
    locale_location = request.user_preferred_languages.first.split(/[-_\s]/, 2)[1] rescue nil
    params[:loc] || locale_location || ip_location
  end
  helper_method :request_location
  
  def stash_controller
    Thread.current[:controller] = self
  end
  
  def localize
    I18n.locale = current_user.try(:locale) || request.compatible_language_from(I18n.available_locales) || I18n.default_locale
    if logged_in?
      attributes = {}
      attributes[:locale] = I18n.locale if current_user.locale.nil?
      attributes[:location] = request_location if current_user.location != request_location
      current_user.update_attributes(attributes) if logged_in? && attributes.present?
    end
  end
  
  def record_user_event(event, value=nil)
    event = Event.lookup(event) if event.kind_of? String
    UserEvent.create! do |ue|
      ue.user_id = current_user.try(:id) || -1
      ue.event_id = event
      ue.value = value.to_s
      ue.locale = I18n.locale
    end
  end
end
