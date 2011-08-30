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

  def getspot
    store = "itunes" if request.user_agent =~ /iPhone/
    store ||= params[:store]
    url = MobileApp.url_for(request_location, store)
    flash[:error] = "Hold Tight. Spot is Coming Soon to an App Store Near You." unless url
    redirect_to  url || root_path
  end  
end