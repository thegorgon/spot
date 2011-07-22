class Site::PromoCodesController < Site::BaseController
  def show
    @code = PromoCode.find_by_code(params[:code])
    render :json => {:code => @code}
  end
end