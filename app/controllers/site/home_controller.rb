class Site::HomeController < Site::BaseController
  layout "oreo"
  
  def index
    if current_user.try(:city) && !params[:stay]
      redirect_to city_path(current_user.city)
    else
      @cities = City.visible      
      render :layout => "site.html"
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
end