class Admin::BusinessesController < Admin::BaseController
  def index
    @businesses = Business.filter(params[:filter].to_i)
    @businesses = @businesses.page(params[:page])
    @businesses = @businesses.per_page(params[:per_page]) if params[:per_page]
    @businesses = @businesses.all
  end
  
  def toggle
    @business = Business.find(params[:id])
    @business.toggle_verification!
    respond_to do |format|
      format.html { redirect_to admin_business_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @business.reload, :as => :business) } }
    end
  end

  def toggle_account
    @business = Business.find(params[:id])
    @business.business_account.toggle_verification!
    respond_to do |format|
      format.html { redirect_to admin_business_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @business.reload, :as => :business) } }
    end
  end
end