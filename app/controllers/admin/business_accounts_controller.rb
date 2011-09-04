class Admin::BusinessAccountsController < Admin::BaseController  
  def index
    @accounts = BusinessAccount.filter(params[:filter].to_i)
    @accounts = @accounts.page(params[:page]).per(params[:per_page])
  end
  
  def destroy
    @account = BusinessAccount.find(params[:id])
    @account.destroy
    respond_to do |format|
      format.html { redirect_to admin_businesses_path }
      format.js { render :json => { :success => true, :html => nil } }
    end
  end
  
  def toggle
    @account = BusinessAccount.find(params[:id])
    @account.toggle_verification!
    respond_to do |format|
      format.html { redirect_to admin_business_path }
      format.js { render :json => { :success => true, :html => render_to_string(:partial => "row", :object => @account.reload, :as => :account) } }
    end
  end
end