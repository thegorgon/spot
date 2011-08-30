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
    session[:invite_code] = params[:ic] # save to session
    session[:promo_code] = params[:pc]
    if params[:asrc].present?
      source = AcquisitionSource.find_by_id(params[:asrc])
      source_id = source.try(:id)
      session[:original_acquisition_source_id] ||= source_id # or equal, only set if not yet set
      session[:acquisition_source_id] = source_id # resets, always store
      source.clicked!(current_user)
      record_acquisition_event("click")
    end
    invitation_code = InvitationCode.valid_code(params[:ic])
    city = City.find_by_slug(params[:cid]) if params[:cid]
    city ||= invitation_code.try(:user).try(:city)
    redirect_to city ? city_path(city) : root_path
  end
end