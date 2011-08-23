class Admin::Acquisition::CampaignsController < Admin::BaseController
  def index
    @campaigns = AcquisitionCampaign.filter(params)
    @new_campaign = AcquisitionCampaign.new
  end
  
  def create
    @campaign = AcquisitionCampaign.new(params[:acquisition_campaign])
    if @campaign.save
      flash[:notice] = "Created Campaign #{@campaign.name}"
      redirect_to admin_acquisition_campaigns_path
    else
      flash[:error] = "There were errors. Please Try Again!"
      @new_campaign = @campaign
      render :action => :index
    end
  end
end