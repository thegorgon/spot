class Admin::MembershipApplicationsController < Admin::BaseController
  def index
    @applications = MembershipApplication.filter(params[:filter].to_i)
    @applications = @applications.page(params[:page]).per(params[:per_page])
  end
  
  def destroy
    @application = MembershipApplication.find(params[:id])
    @application.user.destroy
    respond_to do |format|
      format.html { redirect_to admin_application_path }
      format.js { render :json => { :success => true, :html => nil } }
    end
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