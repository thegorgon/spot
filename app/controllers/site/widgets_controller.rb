class Site::WidgetsController < Site::BaseController
  layout "/site/widgets/layout"

  def show
    @place = Place.find_by_id(params[:id]) if params[:id]
  end
end