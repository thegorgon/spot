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
    redirect_to MobileApp.url_for(location, store) || root_path
  end
end