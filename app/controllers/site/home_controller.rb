class Site::HomeController < Site::BaseController
  def index
  end
  
  def about
  end
  
  def press
  end
      
  def getspot
    store = "itunes" if request.user_agent =~ /iPhone/
    store ||= params[:store]
    url = MobileApp.url_for(request_location, store)
    flash[:error] = "Hold Tight. Spot is Coming Soon to an App Store Near You." unless url
    redirect_to  url || root_path
  end
  
  def email
    @template = params[:tpl]
    @email = params[:e]
    @title = params[:t]
    @user = current_user
    render :template => params[:tpl], :layout => "mailer.html"
  end  
end