class Admin::Acquisition::SourcesController < Admin::BaseController
  def index
    @sources = AcquisitionSource.filter(params)
    @new_source = AcquisitionSource.new
    @campaigns = AcquisitionCampaign.all
  end
  
  def create
    @source = AcquisitionSource.new(params[:acquisition_source])
    if @source.save
      flash[:notice] = "Created Source #{@source.name}"
      redirect_to admin_acquisition_sources_path
    else
      flash[:error] = "There were errors. Please Try Again!"
      @new_source = @source
      render :action => :index
    end
  end
  
end