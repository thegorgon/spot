class Admin::MembershipApplicationsController < Admin::BaseController
  def index
    @applications = MembershipApplication.filter(params[:filter].to_i)
    @applications = @applications.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def toggle
    @application = MembershipApplication.find_by_token(params[:id])
    raise ActiveRecord::RecordNotFound unless @application
    @application.toggle_approval!
    respond_to do |format|
      format.html { redirect_to admin_application_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @application.reload, :as => :application) } }
    end
  end
end