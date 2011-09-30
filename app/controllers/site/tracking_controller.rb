class Site::TrackingController < Site::BaseController
  def user_event
    record_user_event(params[:event], params[:value])
    head :ok
  end
  
  def acquisition_event
    record_acquisition_event(params[:event], params[:value])
    head :ok
  end
  
  def clear
    set_session_invite nil
    set_session_promo nil
    session[:acquisition_source_id] = nil
    session[:original_acquisition_source_id] = nil
    session[:seen_city_intro] = nil
    set_invite_request nil
    redirect_to root_path
  end
  
  def portal
    set_session_invite params[:mc]
    set_session_promo params[:mc]
    
    if params[:ir] && ir = InviteRequest.find_by_id(params[:ir])
      set_invite_request(ir)
    end
    
    if params[:asrc].present?
      source = AcquisitionSource.find_by_id(params[:asrc])
      source_id = source.try(:id)
      session[:original_acquisition_source_id] ||= source_id # or equal, only set if not yet set
      session[:acquisition_source_id] = source_id # resets, always store
      source.clicked!(current_user)
      record_acquisition_event("click")
    end
    invite_request.mark_sent! if invite_request && session[:invite_code]
    
    @city = City.find_by_id(params[:cid]) if params[:cid]
    destination   =  CGI.unescape(params[:dest]) if params[:dest]
    destination ||= city_path(@city) if @city
    destination ||= root_path
    redirect_to destination
  end  
end