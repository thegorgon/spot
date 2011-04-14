class Site::PlacesController < Site::BaseController
  layout 'emptysite'

  caches_action :show,
    :cache_path => Proc.new { |c| [c.send(:place_path, c.params[:id]), c.send(:locale), REVISION].join('/').gsub(/^\//, '') },
    :expires_in => 1.week
  
  def show
    @place = Place.find(params[:id])
    @place = @place.canonical
  end
end