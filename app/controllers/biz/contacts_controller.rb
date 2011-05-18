class Biz::ContactsController < Biz::BaseController
  def new
  end
  
  def create
    BusinessMailer.contact(current_account, params[:contact]).deliver!
    flash[:notice] = "Your message has been sent. We'll be in touch shortly."
    redirect_to current_account ? biz_account_path : biz_root_path
  end  
end