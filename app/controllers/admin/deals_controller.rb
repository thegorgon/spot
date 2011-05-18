class Admin::DealsController < Admin::BaseController
  def index
    @deals = DealTemplate.filter(params[:filter].to_i)
    @deals = @deals.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def edit
    @deal = DealTemplate.find(params[:id])
  end
  
  def update
    @deal = DealTemplate.find(params[:id])
    @deal.attributes = params[:deal_template]
    respond_to do |format|
      if @deal.save
        @message = "#{@deal.name} Saved!"
        format.html do
          flash[:notice] = @message
          redirect_to(edit_admin_deal_path(@deal))
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
          render :json => {:success => false, :message => "#{@message} #{@deal.errors.full_messages}"}
        end
      end
    end
  end  
end