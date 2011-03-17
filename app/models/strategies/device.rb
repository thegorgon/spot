class Strategies::Device < Warden::Strategies::Base
  def valid?
    params[:credentials] && params[:credentials][:device] && params[:credentials][:device][:id] && params[:credentials][:key].present? 
  end

  def authenticate!
    nonce = Nonce.new(:session => session)
    if params[:credentials][:key] == nonce.digested
      device = ::Device.find_or_initialize_by_udid(params[:credentials][:device][:id])
      device.attributes = params[:credentials][:device].except(:id)
      device.save      
    end
    nonce.clear
    device && device.user ? success!(device.user) : fail!("Inalid device parameters")
  end
end