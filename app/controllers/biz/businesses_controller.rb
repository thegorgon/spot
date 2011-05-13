class Biz::BusinessesController < Biz::BaseController
  before_filter :require_business, :except => [:new, :create, :search]

  def new
  end

  def edit
  end
  
  def update
    @business.attributes = params[:business].except(:place_attributes)
    @business.place.attributes = params[:business][:place_attributes]
    if @business.verified? && @business.save
      redirect_to edit_biz_business_path(@business)
    else
      flash[:error] = @business.verified?? 
        "We had some errors with your submission." : 
        "Sorry, you need to be verified before you can edit your entry."
      @page_namespace = "biz_businesses_edit"
      render :action => :edit
    end
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