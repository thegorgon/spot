class Biz::DiscountCodesController < Biz::BaseController
  before_filter :require_business
  
  def index
    @date = Time.at(params[:date_seconds].to_f).to_date if params[:date_seconds]
    @date ||= Date.today
    @events = @business.deal_events.on_date(@date).includes(:deal_codes => :owner).all
    respond_to do |format|
      format.html
      format.js { render :json => {:html => render_to_string(:partial => "codes")}}
    end
  end
  
  def lookup
    @code = @business.deal_codes.where(:code => params[:code]).first
    respond_to do |format|
      format.html
      format.js { render :json => {:html => render_to_string(:partial => "code", :object => @code)}}
    end
  end

  def mail
    success = @business.deliver_deal_codes_for! params[:date]
    respond_to do |format|
      format.html { redirect_to biz_business_codes_path(@business) }
      format.js { render :json => {:success => success, :flash => success ? "Discount codes sent. Check your email." : "No codes for that date."} }
    end
  end
  
  def redeem
    @code = @business.deal_codes.find(params[:id])
    @code.redeem!
    @event = @code.deal_event
    respond_to do |format|
      format.html { redirect_to biz_business_codes_path(@business) }
      format.js { render :json => { :event_id => @event.id,
                                    :code_id => @code.id,
                                    :code => render_to_string(:partial => "code", :object => @code),
                                    :event => render_to_string(:partial => "event", :object => @event) } }
    end
  end

  private
  
  def require_business
    @business = current_account.businesses.find(params[:business_id])
    redirect_to new_biz_business_path unless @business
  end
end