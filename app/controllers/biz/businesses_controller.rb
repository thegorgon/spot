class Biz::BusinessesController < Biz::BaseController
  def new
  end

  def edit
    @business = current_account.businesses.find(params[:id])
  end
  
  def create
    @business = current_account.claim(params[:business])
    if @business.save
      redirect_to biz_business_path(@business)
    else
      flash[:error] = @business.errors.full_messages
      redirect_to biz_account_path
    end
  end

  def search
    @search = PlaceSearch.from_params(params[:search])
    respond_to do |format|
      format.html
      format.js { render :json => { :html => render_to_string(:partial => "search") }}
    end
  end
  
  def show
    @business = current_account.businesses.find(params[:id])
  end
end