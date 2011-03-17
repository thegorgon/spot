class Api::SessionsController < Api::BaseController
  skip_before_filter :require_user, :except => :destroy
  
  def new
    @nonce = Nonce.new(:session => session)
    render :json => { :nonce => @nonce.token }
  end
  
  def create
    require_user
    render :json => { :user => current_user }
  end
  
  def destroy
    logout
    head :ok
  end
end