class Strategies::Device < Warden::Strategies::Base
  def valid?
    params[:credentials] && 
      params[:credentials][:device] && 
      params[:credentials][:device][:id]  
  end

  def authenticate!
    device = ::Device.authenticate(params[:credentials]) if Nonce.valid?(params, session)
    device && device.user ? success!(device.user) : fail!("Inalid device parameters")
  end
end