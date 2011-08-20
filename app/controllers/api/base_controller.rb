class Api::BaseController < ApplicationController
  before_filter :log_session
  before_filter :require_user
  before_filter :log_device_specs
  rescue_from Exception, :with => :exception_handler
  
  private
  
  def device_specifications
    unless @device_specifications
      #"Spot 1.1.2 rv:72 (iPhone Simulator; iPhone OS 5.0; en_US)"
      /Spot ([\d\.]+) rv:(\d+) \(([^\;]+); ([^\;]+); ([^\)]+)\)/.match(request.user_agent) do |match|
        @device_specifications = {
          :revision => match[1].to_i,
          :app_version => match[2].to_i,
          :device_name => match[3].to_i,
          :os_id => match[4].to_i,
          :locale => match[5].to_i,
        }
      end
    end
    @device_specifications || {}
  end
  
  def log_device_specs
    description = device_specifications.map { |key, value|  "#{key.to_s.humanize.titlecase}: #{value}" }.join(", ")
    Rails.logger.info("spot: handling request from user-agent: #{request.user_agent}")
    Rails.logger.info("spot: parsed user agent into device : #{description}")
  end
  
  def log_session
    Rails.logger.info("spot: session = #{session.inspect} and cookies = #{request.cookies.inspect}")
  end
  
  def exception_handler(exception=nil)
    Rails.logger.info("spot: handling exception of type : #{exception.class}")
    log_error(exception)
    record_user_event("api exception", exception.class.to_s)
    
    case exception
    when ActiveRecord::RecordNotUnique
      duplicate_record_error(exception)
    when ActiveRecord::RecordInvalid
      invalid_record_error(exception)
    when ActiveRecord::RecordNotFound
      record_not_found_error(exception)
    when ServiceError
      service_error(exception)
    when UnauthorizedAccessError
      unauthorized_access_error(exception)
    else
      unknown_error(exception)
    end
  end
  
  def basic_exception(status, exception=nil, headers={})
    headers = {:exception_body => exception.try(:message), :exception_type => exception.class.to_s}.merge!(headers)
    Rails.logger.info("spot: rendering error : #{status}, #{headers.inspect}")
    head(status, headers)
  end
  
  def service_error(exception=nil)
    basic_exception(503, exception, :retry_after => 0)
  end

  def unauthorized_access_error(exception=nil)
    warden.custom_failure!
    basic_exception(401, exception, :www_authenticate => "Api")
  end
  
  def record_not_found_error(exception=nil)
    basic_exception(404, exception)
  end
  
  def invalid_record_error(exception=nil)
    basic_exception(403, exception)
  end
  
  def duplicate_record_error(exception=nil)
    basic_exception(409, exception)
  end
  
  def unknown_error(exception=nil)
    if Rails.env.production?
      basic_exception(500, exception)
    else
      raise exception
    end
  end
  
  def require_user    
    authenticate
    Rails.logger.info("spot: requiring user, current user id : #{current_user.try(:id)}")
    raise UnauthorizedAccessError, "An active user session is required to access this resource." unless logged_in?
  end
end