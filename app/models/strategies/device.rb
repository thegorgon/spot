class Strategies::Device < Warden::Strategies::Base
  def valid?
    Rails.logger.info("warden: testing validity of device strategy")
    params[:credentials] && 
      params[:credentials][:device] && 
      params[:credentials][:device][:id]
  end

  def authenticate!
    Rails.logger.info("warden: attempting authentication with device strategy")
    device = ::Device.authenticate(params[:credentials]) if Nonce.valid?(params, session)
    device && device.user ? success!(device.user) : fail!("Inalid device parameters")
  end
end