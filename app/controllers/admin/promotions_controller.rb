class Admin::PromotionsController < Admin::BaseController
  def index
    @promotions = PromotionTemplate.filter(params[:filter].to_i)
    @promotions = @promotions.page(params[:page])
    @promotions = @promotions.per_page = params[:per_page] if params[:per_page]
    @promotions = @promotions.all
  end
    
  def destroy
    @promotion = PromotionTemplate.find(params[:id])
    @promotion.destroy
    flash[:notice] = "#{@promotion.name} Deleted!"
    redirect_to admin_promotions_path(params.slice("filter"))
  end
  
  def update
    @promotion = PromotionTemplate.find(params[:id])
    @promotion.attributes = params[:template]
    respond_to do |format|
      if @promotion.save
        @message = "#{@promotion.name} Saved!"
        format.html do
          flash[:notice] = @message
          redirect_to admin_promotions_path(params.slice("filter"))
        end
        format.js do
          index
          render :json => {:success => true, :html => render_to_string(:action => :index, :layout => false)}
        end
      else
        @message = "There were errors with your submission"
        format.html do
          flash.now[:error] = @message
          render(:action => "edit")
        end
        format.js do
          render :json => {:success => false, :message => "#{@message} #{@promotion.errors.full_messages}"}
        end
      end
    end
  end  
end