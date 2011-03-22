class Strategies::Password < Warden::Strategies::Base
  def valid?
    params[:credentials] &&
      params[:credentials][:password] &&
      params[:credentials][:password][:login] &&
      params[:credentials][:password][:password]
  end
  
  def authenticate!
    if Nonce.valid?(params, session) && account = PasswordAccount.authenticate(params[:credentials][:password])
      ::Device.user_associate(account.user, params[:credentials])
      success!(account.user)
    else
      fail!("Invalid login")
    end
  end
end