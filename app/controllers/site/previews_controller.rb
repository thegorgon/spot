class Site::PreviewsController < Site::BaseController
  def create
    @preview = PreviewSignup.signup(params[:preview])
    if @preview.save
      redirect_to preview_share_path(@preview.rid)
    else
      redirect_to root_path
    end
  end
  
  def share
    @preview = PreviewSignup.find_by_rid(params[:preview_id])
  end
end