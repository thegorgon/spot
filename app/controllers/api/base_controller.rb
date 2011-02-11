class Api::BaseController < ApplicationController
  rescue_from ServiceError, :with => :service_exception
  rescue_from Authlogic::Session::Existence::SessionInvalidError, :with => :unauthorized_access_error
  rescue_from UnauthorizedAccessError, :with => :unauthorized_access_error
  
  private
  
  def basic_exception(status, exception=nil, headers={})
    headers.merge!(:exception_body => exception.try(:message), :exception_type => exception.class.to_s)
    head(status, headers)
  end
  
  def service_exception(exception=nil)
    basic_exception(503, exception, :retry_after => 0)
  end

  def unauthorized_access_error(exception=nil)
    basic_exception(401, exception, :www_authenticate => "Api")
  end
  
  def require_user
    raise UnauthorizedAccessError, "An active user session is required to access this resource." unless current_user
  end

end