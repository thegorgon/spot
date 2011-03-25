class Strategies::PerishableToken < Warden::Strategies::Base
  def valid?
    token.present?
  end

  def authenticate!
    user = User.find_using_perishable_token(token)
    if user && Nonce.valid?(params, session)
      ::Device.user_associate(user, params[:credentials])
      user.reload
    end
    user.try(:reset_perishable_token!)
    user ? success!(user) : fail!("Invalid token")
  end
  
  def token
    if request.get?
      params[:token]
    elsif request.post?
      params[:credentials] && params[:credentials][:token]
    else
      nil
    end
  end
end