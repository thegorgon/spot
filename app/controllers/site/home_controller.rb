class Site::HomeController < Site::BaseController
  layout "oreo"
  
  def index
    clear_partial_application
    if current_user.try(:city)
      redirect_to city_path(current_user.city)
    else
      render :layout => "site"
    end
  end
  
  def about
  end
  
  def press
  end
  
  def about_membership
  end
  
  def privacy
  end
  
  def tos
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

  def getspot
    store = "itunes" if request.user_agent =~ /iPhone/
    store ||= params[:store]
    url = MobileApp.url_for(request_location, store)
    flash[:error] = "Hold Tight. Spot is Coming Soon to an App Store Near You." unless url
    redirect_to  url || root_path
  end  
end