class Strategies::PerishableToken < Warden::Strategies::Base
  def valid?
    Rails.logger.info("warden: testing validity of perishable token strategy")
    token.present?
  end

  def authenticate!
    Rails.logger.info("warden: attempting authentication with perishable token strategy")
    user = User.find_using_perishable_token(token)
    if user && Nonce.valid?(params, session)
      ::Device.user_associate(user, params[:credentials])
      user.reload
    end
    user ? success!(user) : fail!("Invalid token")
  end
  
  def token
    if get_params[:token] && get_params[:token].present?
      get_params[:token]
    elsif post_params[:credentials] && post_params[:credentials][:token].present?
      post_params[:credentials][:token]
    else
      nil
    end
  end
  
  def store?
    false
  end
  
  private
  
  def get_params
    @get_params ||= HashWithIndifferentAccess.new(request.GET)
  end
  
  def post_params
    @post_params ||= HashWithIndifferentAccess.new(request.POST || {})
  end
end