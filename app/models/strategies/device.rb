class Strategies::Device < Warden::Strategies::Base
  def valid?
    params[:credentials] && params[:credentials][:device] && params[:credentials][:device][:id] 
  end

  def authenticate!
    nonce = Nonce.new(:session => session)
    device = ::Device.authenticate(params[:credentials]) if params[:credentials][:key] == nonce.digested
    nonce.clear
    device && device.user ? success!(device.user) : fail!("Inalid device parameters")
  end
end