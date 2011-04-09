class Site::PreviewsController < Site::BaseController
  def create
    @preview = PreviewSignup.signup(params[:preview])
    success = @preview.save
    redirect_to preview_share_url(@preview.rid)
  end
  
  def share
    @preview = PreviewSignup.find_by_rid(params[:preview_id])
  end
end