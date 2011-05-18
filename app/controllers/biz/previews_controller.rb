class Biz::PreviewsController < Biz::BaseController
  skip_before_filter :require_admin
  skip_before_filter :require_account
  
  layout 'site'
  
  def index
  end
  
  def create
    @preview = PreviewSignup.signup(params[:preview])
    if @preview.save
      flash[:notice] = "Thank you for your interest. We'll be in touch."
    else
      flash[:error] = "Sorry, there was an error with your submission, please try again."
    end
    redirect_to root_path
  end
  
  def show
    @preview = PreviewSignup.find_by_rid(params[:preview_id])
  end
end