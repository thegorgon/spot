class PublicErrorsController < ApplicationController
  layout 'site'
  
  def internal_server_error
    render :template => '/errors/internal_server_error', :layout => 'site'
  end

  def not_found
    render :template => '/errors/not_found', :layout => 'site'
  end

  def routing_error
    not_found
  end

  def unprocessable_entity
    internal_server_error
  end

  def conflict
    internal_server_error
  end

  def method_not_allowed
    not_found
  end

  def not_implemented
    internal_service_error
  end
  
end