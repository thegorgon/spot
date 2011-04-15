class Admin::SettingsController < Admin::BaseController
  def index
    @settings = AppSetting.all
  end
  
  def available
    exists = AppSetting.where(:key => params[:value]).exists?
    render :json => {:valid => !exists}
  end
  
  def update
    AppSetting.set!(params[:id], params[:setting][:value])
    redirect_to admin_settings_path
  end
  
  def create
    AppSetting.create!(params[:setting])
    redirect_to admin_settings_path
  end
  
  def destroy
    AppSetting.remove!(params[:id])
    redirect_to admin_settings_path
  end
end