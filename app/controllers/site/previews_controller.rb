class Site::PreviewsController < Site::BaseController
  def index
    respond_to do |format|
      format.html 
      format.js { default_page_render }
    end
  end
  
  def create
    @preview = PreviewSignup.signup(params[:preview])
    success = @preview.save
    respond_to do |wants|
      wants.html
      wants.js do 
        if success
          default_page_render
        else
          render :json => { :errors => @preview.errors.full_messages }
        end
      end
    end
  end
end