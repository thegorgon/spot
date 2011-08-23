class Admin::MembershipApplicationsController < Admin::BaseController
  def index
    @applications = MembershipApplication.filter(params[:filter].to_i)
    @applications = @applications.page(params[:page])
    @applications = @applications.per_page(params[:per_page]).all if params[:per_page]
    @applications = @applications.all
  end
  
  def toggle
    @application = MembershipApplication.find(params[:id])
    @application.toggle_approval!
    respond_to do |format|
      format.html { redirect_to admin_application_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @application.reload, :as => :application) } }
    end
  end
end