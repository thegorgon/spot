class Strategies::Facebook < Warden::Strategies::Base
  def valid?
    params[:credentials] && 
      params[:credentials][:facebook] && 
      params[:credentials][:facebook][:access_token] &&
      params[:credentials][:facebook][:facebook_id]
  end

  def authenticate!
    account = FacebookAccount.authenticate(params[:credentials][:facebook]) if Nonce.valid?(params, session) 
    account && account.user ? success!(account.user) : fail!("Invalid facebook parameters")
  end
end