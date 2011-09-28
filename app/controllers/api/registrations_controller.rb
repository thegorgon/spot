class Api::RegistrationsController < Api::BaseController
  def create
    @registration = Registration.new(params[:registration])
    @registration.user = current_user
    @registration.save!
    render :json => @registration.code
  end
  
  def destroy
    @code = current_user.codes.find(params[:id])
    @code.unissue!
    head :ok
  end
end