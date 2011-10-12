class Site::InviteRequestsController < Site::BaseController
  def update
    @request = InviteRequest.find(params[:id])
    @request.attributes = params[:request]
    
    if @request.save
      @request.reload
      set_invite_request @request
    else
      flash[:error] = "Sorry, that didn't seem to work."
    end
    redirect_to @request.city ? city_path(@request.city) : new_city_path
  end
  
  def create
    @request = InviteRequest.with_attributes(params[:request])
    if @request.save
      record_acquisition_event("email acquired")
      set_invite_request @request
      redirect_to @request.city ? city_path(@request.city) : new_city_path
    else
      flash[:error] = "Sorry, that email didn't work. Please try again."
      redirect_to root_path
    end
  end
end