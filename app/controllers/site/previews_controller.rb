class Site::PreviewsController < Site::BaseController
  def index
  end
  
  def create
    @preview = PreviewSignup.signup(params[:preview])
    if @preview.save
      redirect_to preview_share_url(@preview.rid)
    else
      redirect_to previews_url
    end
  end
  
  def share
    @preview = PreviewSignup.find_by_rid(params[:preview_id])
  end
end