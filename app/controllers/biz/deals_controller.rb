class Biz::DealsController < Biz::BaseController
  before_filter :require_business

  def index
    @events = @business.deal_events.all
    respond_to do |format|
      format.js { render :json => {:success => true, :events => @events.group_by { |e| e.date.to_s() }} }
    end
  end
  
  def create
    @event = @business.deal_events.new(params[:event])
    respond_to do |format|
      if @event.save
        format.js { render :json => {:success => true, :event => @event} }
        format.html { redirect_to calendar_biz_business_path(@business) }
      else
        format.js { render :json => {:success => false, :error => @event.errors.full_messages.join(", ")} }
      end
    end
  end
  
  def destroy
    @event = @business.deal_events.find(params[:id])
    @event.remove!
    respond_to do |format|
      format.js { render :json => {:success => true, :event => @event.destroyed?? nil : @event} }
      format.html { redirect_to calendar_biz_business_path(@business) }
    end
  end
  
  def update
  end

  private
  
  def require_business
    @business = current_account.businesses.find(params[:business_id])
    redirect_to new_biz_business_path unless @business
  end
end