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

    warden.set_user User.select("users.*").
                      joins("INNER JOIN devices ON devices.user_id = users.id LEFT JOIN password_accounts ON password_accounts.user_id = users.id").
                      where("password_accounts.id IS NULL").first
    if params[:dest] == "about"
      redirect_to mobile_siteify(membership_about_path)
    elsif params[:dest] == "login"
      redirect_to mobile_siteify(new_session_path)
    else
      redirect_to mobile_siteify(new_application_path)
    end
  end
  
  def exit
    left_mobile_app!
    
    redirect_to "spot-app://finished"
  end
end