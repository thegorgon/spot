class Api::BaseController < ApplicationController
  rescue_from ServiceException, :with => :service_exception
  
  private
  
  def service_exception(exception=nil)
    head 503, :retry_after => 0, :exception_body => exception.message, :exception_type => exception.class.to_s
  end
end