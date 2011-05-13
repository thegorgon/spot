class Api::BaseController < ApplicationController
  before_filter :require_user
  
  rescue_from Exception, :with => :exception_handler
  
  private
  
  def exception_handler(exception=nil)
    Rails.logger.info("spot-app: handling exception of type : #{exception.class}")
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
    Rails.logger.info("spot-app: rendering error : #{status}, #{headers.inspect}")
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
    Rails.logger.info("spot-app: requiring user, current user id : #{current_user.try(:id)}")
    raise UnauthorizedAccessError, "An active user session is required to access this resource." unless logged_in?
  end
end