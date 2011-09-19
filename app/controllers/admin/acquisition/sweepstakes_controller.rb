class Admin::Acquisition::SweepstakesController < Admin::BaseController
  def index
    @sweepstakes = Sweepstake.filter(params)
    @new_sweepstake ||= Sweepstake.new
    render :action => :index
  end
  
  def create
    @sweepstake = Sweepstake.new(params[:sweepstake])
    if @sweepstake.save
      flash[:notice] = "Created Sweepstake \"#{@sweepstake.name}\""
      redirect_to admin_acquisition_sweepstakes_path
    else
      flash[:error] = "There were errors. Please Try Again!"
      @new_sweepstake = @sweepstake
      index
    end
  end
  
  def edit
    @sweepstake = Sweepstake.find(params[:id])
  end
  
  def update
    @sweepstake = Sweepstake.find(params[:id])
    @sweepstake.attributes = params[:sweepstake]
    if @sweepstake.save
      flash[:notice] = "Saved Sweepstake \"#{@sweepstake.name}\""
      redirect_to admin_acquisition_sweepstake_path(@sweepstake)
    else
      flash[:error] = "There were errors. Please Try Again!"
      render :action => :edit
    end
  end
  
  def destroy
    @sweepstake = Sweepstake.find(params[:id])
    @sweepstake.destroy
    redirect_to admin_acquisition_sweepstakes_path
  end
  
  def show
    redirect_to edit_admin_acquisition_sweepstake_path(params[:id])
  end
end