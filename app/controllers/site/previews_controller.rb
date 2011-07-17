class Site::PreviewsController < Site::BaseController  
  def create
    @preview = PreviewSignup.signup(params[:preview])
    if @preview.save
      flash[:notice] = "Thank you for your interest. We'll be in touch."
      redirect_to root_path
    else
      flash[:error] = "Sorry, there was an error with your submission, please try again."
      redirect_to params[:return_to] || root_path
    end
  end
end