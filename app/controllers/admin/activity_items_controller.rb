class Admin::ActivityItemsController < Admin::BaseController
  def index
    @position = Geo::LatLng.normalize(params[:ll] || "0,0")
    params[:device] ||= {:app_version => 100}
    params[:radius] = ActivityItem::DEFAULT_RADIUS if params[:local].to_i > 0
    @items = ActivityItem.feed(params)
    respond_to do |format|
      format.html
      format.js { render :json => { :html => render_to_string(:partial => "results") }}
    end
  end
end