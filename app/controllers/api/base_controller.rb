class Api::BaseController < ApplicationController
  before_filter :require_user
  
  rescue_from Exception, :with => :exception_handler
  
  private
  
  def exception_handler(exception=nil)
    Rails.logger.info("Handling exception of type : #{exception.class}")
    
    case exception
    when ActiveRecord::RecordNotUnique
      duplicate_record_error(exception)
    when ActiveRecord::RecordInvalid
      invalid_record_error(exception)
    when ActiveRecord::RecordNotFound
      record_not_found_error(exception)
    when ServiceError
      service_error(exception)
    when Authlogic::Session::Existence::SessionInvalidError, UnauthorizedAccessError
      unauthorized_access_error(exception)
    else
      unknown_error(exception)
    end
  end
  
  def basic_exception(status, exception=nil, headers={})
    headers = {:exception_body => exception.try(:message), :exception_type => exception.class.to_s}.merge!(headers)
    Rails.logger.info("Rendering error : #{status}, #{headers.collect { |k, v| "#{k}=#{v}" }.join}")
    head(status, headers)
  end
  
  def service_error(exception=nil)
    basic_exception(503, exception, :retry_after => 0)
  end

  def unauthorized_access_error(exception=nil)
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
    basic_exception(500, exception)
  end
  
  def require_user
    Rails.logger.info("Requiring user, current user ID : #{current_user.try(:id)}")
    raise UnauthorizedAccessError, "An active user session is required to access this resource." unless current_user
  end

end