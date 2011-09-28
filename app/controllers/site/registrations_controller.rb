class Site::RegistrationsController < Site::BaseController
  layout "oreo"
  before_filter :require_membership
  before_filter :require_user
  before_filter :require_ownership_of_code, :only => [:show, :destroy]
  
  def new
    @event = PromotionEvent.find(params[:eid])
    @code = current_user.codes.for_event(@event).first
    if @code
      redirect_to registration_path(@code)
    else
      @promotion = @event.template
      @place = @event.place
    end
  end
  
  def create
    @registration = Registration.new(params[:registration])
    @registration.user = current_user
    respond_to do |format|
      if @registration.save
        record_acquisition_event("registration")
        format.html { redirect_to registration_path(@registration) }
        format.js do
          render :json => { :code => render_to_string(:partial => "code"), 
                            :calendar => render_to_string(:partial => "/site/events/calendar", :locals => {:promotion => @registration.promotion}) }
        end
      else
        format.html do 
          flash[:error] = @registration.errors[:base]
          redirect_back_or_default account_path
        end
        format.js { render :json => {:error => @registration.errors[:base].join(", ") } }
      end
    end
  end
  
  def show
    @registration = Registration.new
    @registration.code = @code
    @registration.event = @code.event
    @registration.user = current_user
  end

  def destroy
    @code.unissue!
    redirect_back_or_default account_path
  end
  
  private
  
  def require_ownership_of_code
    @code = current_user.codes.find(params[:id])
  end
end