class Api::SessionsController < Api::BaseController
  skip_before_filter :require_user, :except => :destroy
  
  def new
    render :json => { :nonce => UserSession.generate_nonce }
  end
  
  def create
    @session = UserSession.new(params[:credentials])
    # API Point Has Memory and Requires Nonce Key
    @session.require_credential_key = @session.remember_me = true 
    @session.save!
    render :json => { :user => @session.user }
  end
  
  def destroy
    current_user_session.destroy
    head :ok
  end
end