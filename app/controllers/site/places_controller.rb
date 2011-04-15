class Site::PlacesController < Site::BaseController
  layout 'emptysite'

  caches_action :show,
    :cache_path => Proc.new { |c| AppSetting.cache_path(:blog, c) },  
    :expires_in => 1.week
  
  def show
    @place = Place.find(params[:id])
    @place = @place.canonical
  end
end