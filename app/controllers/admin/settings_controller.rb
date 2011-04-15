class Admin::SettingsController < Admin::BaseController
  def index
    @settings = AppSetting.all
  end
  
  def available
    exists = AppSetting.where(:key => params[:value]).exists?
    render :json => {:valid => !exists}
  end
  
  def update
    @setting = AppSetting.find_by_key(params[:id])
    @setting.attributes = params[:setting] if @setting
    success = @setting.try(:save)
    flash[success ? :notice : :error] = success ? "Data Mutated..." : "Nope!"
    redirect_to admin_settings_path
  end
  
  def create
    @setting = AppSetting.new(params[:setting])
    success = @setting.save
    flash[success ? :notice : :error] = success ? "It's alive!" : "Nope!"
    redirect_to admin_settings_path
  end
  
  def destroy
    AppSetting.remove!(params[:id])
    flash[:notice] = "It's gone!"
    redirect_to admin_settings_path
  end
end