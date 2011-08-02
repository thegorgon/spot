class Site::HomeController < Site::BaseController
  layout "oreo"
  
  def index
    render :layout => "site"
  end
  
  def about
  end
  
  def press
  end
  
  def policies
  end
  
  def privacy
  end
      
  def tos
  end

  def invited
    session[:invite_code] = params[:ic] # save to session
    session[:promo_code] = params[:pc]
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
  
  def email
    @template = params[:tpl]
    @email = params[:e]
    @title = params[:t]
    @user = current_user
    redirect_to root_url unless @template && @email && @title
    render :template => params[:tpl], :layout => "mailer.html"
  end  
end