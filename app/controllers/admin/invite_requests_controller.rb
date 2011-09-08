class Admin::InviteRequestsController < Admin::BaseController
  def index
    @requests = InviteRequest.filter(params[:filter].to_i)
    @requests = @requests.page(params[:page]).per(params[:per_page])
  end
  
  def destroy
    @request = InviteRequest.find(params[:id])
    @request.destroy
    respond_to do |format|
      format.html { redirect_to admin_invite_requests_path }
      format.js { render :json => { :success => true, :html => nil } }
    end
  end
  
  def trigger
    @request = InviteRequest.find(params[:id])
    @request.send_invite!
    respond_to do |format|
      format.html { redirect_to admin_invite_requests_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @request.reload, :as => :request) } }
    end
  end
end