class Strategies::Facebook < Warden::Strategies::Base
  def valid?
    params[:credentials] && 
      params[:credentials][:facebook] && 
      params[:credentials][:facebook][:access_token] &&
      params[:credentials][:facebook][:facebook_id]
  end

  def authenticate!
    if Nonce.valid?(params, session) && account = FacebookAccount.authenticate(params[:credentials][:facebook])
      ::Device.user_associate(account.user, params[:credentials])
      success!(account.user)
    else
      fail!("Invalid facebook parameters")
    end
  end
end