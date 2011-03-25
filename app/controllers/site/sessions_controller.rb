class Site::SessionsController < Site::BaseController
  skip_before_filter :require_user, :except => [:destroy]
  
  def new
    @nonce = Nonce.new(:session => session)
  end
  
  def create
    authenticate!
    redirect_back_or_default root_path
  end
  
  def destroy
    logout
    redirect_back_or_default root_path
  end
end