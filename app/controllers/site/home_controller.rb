class Site::HomeController < Site::BaseController
  def index
  end
  
  def about
  end
  
  def press
  end 
  
  def secret
  end

  def getspot
    location = request_location || current_user.try(:location)
    store = "itunes" if request.user_agent =~ /iPhone/
    store ||= params[:store]
    url = MobileApp.url_for(location, store)
    flash[:error] = "Hold Tight. Spot is Coming Soon to an App Store Near You." unless url
    redirect_to  url || root_path
  end
end