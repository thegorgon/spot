class Site::PreviewsController < Site::BaseController
  def index
  end
  
  def create
    @preview = PreviewSignup.signup(params[:preview])
    success = @preview.save
    respond_to do |wants|
      wants.html
      wants.js do 
        if success
          render :json => { :html => render_to_string(:partial => "share") }
        else
          render :json => { :errors => @preview.errors.full_messages }
        end
      end
    end
  end
end