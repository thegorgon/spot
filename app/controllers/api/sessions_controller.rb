class Api::SessionsController < Api::BaseController
  skip_before_filter :require_user, :except => :destroy
  
  def new
    record_user_event("api nonce fetch")
    render :json => { :nonce => nonce.token }
  end
  
  def create
    require_user
    record_user_event("api login")
    render :json => { :user => current_user }
  end
  
  def destroy
    record_user_event("api logout")
    logout
    head :ok
  end
end