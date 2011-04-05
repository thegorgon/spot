class Strategies::Facebook < Warden::Strategies::Base
  def valid?
    Rails.logger.info("warden: testing validity of facebook strategy")
    params[:credentials] && 
      params[:credentials][:facebook] && 
      params[:credentials][:facebook][:access_token] &&
      params[:credentials][:facebook][:facebook_id]
  end

  def authenticate!
    Rails.logger.info("warden: attempting authentication with facebook strategy")
    if Nonce.valid?(params, session) && account = FacebookAccount.authenticate(params[:credentials][:facebook])
      ::Device.user_associate(account.user, params[:credentials])
      success!(account.user)
    else
      fail!("Invalid facebook parameters")
    end
  end
end