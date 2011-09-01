class Site::TrackingController < Site::BaseController
  def user_event
    record_user_event(params[:event], params[:value])
    head :ok
  end
  
  def acquisition_event
    record_acquisition_event(params[:event], params[:value])
    head :ok
  end
  
  def portal
    if params[:mc] && mc = MembershipCode.find_by_code(params[:mc])
      session[:invite_code] = mc.invite.try(:code)
      session[:promo_code] = mc.promo.try(:code)
    end
    
    if params[:asrc].present?
      source = AcquisitionSource.find_by_id(params[:asrc])
      source_id = source.try(:id)
      session[:original_acquisition_source_id] ||= source_id # or equal, only set if not yet set
      session[:acquisition_source_id] = source_id # resets, always store
      source.clicked!(current_user)
      record_acquisition_event("click")
    end
    redirect_to params[:dest] ? CGI.unescape(params[:dest]) : root_path
  end
end