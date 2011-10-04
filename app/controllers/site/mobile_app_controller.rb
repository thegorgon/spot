class Site::MobileAppController < Site::BaseController
  def download
    store = "itunes" if request.user_agent =~ /iPhone/
    store ||= params[:store]
    url = MobileApp.url_for(request_location, store)
    flash[:error] = "Hold Tight. Spot is Coming Soon to an App Store Near You." unless url
    redirect_to  url || root_path
  end

  def entrance
    in_mobile_app!
    
    set_session_invite InvitationCode.device_code.try(:code)
    set_session_promo PromoCode.device_code.try(:code)

    if params[:dest] == "about"
      redirect_to mobile_siteify(membership_about_path)
    elsif params[:dest] == "login"
      redirect_to mobile_siteify(new_session_path)
    elsif params[:dest] == "membership"
      redirect_to mobile_siteify(account_path)
    else
      redirect_to mobile_siteify(new_application_path)
    end
  end
  
  def exit
    left_mobile_app!
    redirect_to "spot-app://#{CGI.unescape(params[:dest] || "finished")}" 
  end
end