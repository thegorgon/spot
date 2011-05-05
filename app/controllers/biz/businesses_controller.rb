class Biz::BusinessesController < Biz::BaseController
  before_filter :require_business, :except => [:new, :create, :search]
  def new
  end

  def edit
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
  end
  
  def calendar
  end
  
  private
  
  def require_business
    @business = current_account.businesses.find(params[:id])
    redirect_to new_biz_business_path unless @business
  end
end