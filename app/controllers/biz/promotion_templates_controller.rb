class Biz::PromotionTemplatesController < Biz::BaseController
  before_filter :require_business

  def index
    @templates = @business.promotion_templates.active.all
    respond_to do |format|
      format.js { render :json => {:success => true, :templates => @templates}}
    end
  end
  
  def create
    @template = @business.new_promotion_template(params[:discount] || params[:generic])
    respond_to do |format|
      debugger
      if @template.save
        format.js { render :json => {:success => true, :template => @template} }
        format.html { redirect_to calendar_biz_business_path(@business) }
      else
        format.js { render :json => {:success => false, :error => @template.errors.full_messages.join(", ").downcase} }
      end
    end
  end
    
  def destroy
    @template = @business.promotion_templates.find(params[:id])
    @template.removed!
    respond_to do |format|
      format.js { render :json => {:success => true} }
      format.html { redirect_to calendar_biz_business_path(@business) }
    end
  end

  private
  
  def require_business
    @business = current_account.businesses.find(params[:business_id])
    redirect_to new_biz_business_path unless @business
  end
end