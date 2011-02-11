class Api::BaseController < ApplicationController
  before_filter :require_user
  
  rescue_from ActiveRecord::RecordInvalid, :with => :invalid_record_error
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found_error
  rescue_from ServiceError, :with => :service_exception
  rescue_from Authlogic::Session::Existence::SessionInvalidError, :with => :unauthorized_access_error
  rescue_from UnauthorizedAccessError, :with => :unauthorized_access_error
  
  private
  
  def basic_exception(status, exception=nil, headers={})
    headers = {:exception_body => exception.try(:message), :exception_type => exception.class.to_s}.merge!(headers)
    head(status, headers)
  end
  
  def service_exception(exception=nil)
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
  
  def require_user
    raise UnauthorizedAccessError, "An active user session is required to access this resource." unless current_user
  end

end