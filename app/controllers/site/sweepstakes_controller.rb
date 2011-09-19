class Site::SweepstakesController < Site::BaseController
  before_filter :require_sweepstake
  layout 'site'
  
  def show
    @entry = @sweepstake.entries.find_or_initialize_by_invite_request_id(invite_request.try(:id))
    @entry.invite_request ||= InviteRequest.new
    @place = @sweepstake.place
    @page_title = "#{@sweepstake.name} - Spot"
    @page_description = "Enter to win a #{@sweepstake.short_summary} at #{@sweepstake.place_name}"
    @page_keywords = [@sweepstake.place_name, "sweepstake", "on the house", "free", @sweepstake.short_summary]
    @referrer = SweepstakeEntry.find_by_referral_code(params[:ref]) if params[:ref]
    render :action => :show
  end
  
  def enter
    @request = InviteRequest.with_attributes params[:entry].except("referred_by_id")
    if success = @request.save
      set_invite_request @request
      @entry = @sweepstake.entries.find_or_initialize_by_invite_request_id(@request.id)
      @entry.referred_by_id = params[:entry][:referred_by_id]
      success = @entry.save
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to sweepstake_path(@sweepstake) }
        format.js { render :json => { :success => true, :entry => @entry, :html => render_to_string(:partial => "entry") } }
      else
        format.html { redirect_to sweepstake_path(@sweepstake) }
        format.js { render :json => { :success => false, :errors => @entry.errors} }
      end
    end
  end
  
  def rules
    render :layout => "oreo"
  end

  private
  
  def require_sweepstake
    @sweepstake = Sweepstake.find(params[:id])
  end
end