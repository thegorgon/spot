class PlaceSweeper < ActionController::Caching::Sweeper
  observe Place
  include Rails.application.routes.url_helpers

  def after_update(place)
    Rails.logger.info "place-sweeper: after_update place #{place.to_param}"
    expire_cache_for(place)
  end
  
  def after_create(place)
    Rails.logger.info "place-sweeper: after_create place #{place.to_param}"
    expire_cache_for(place)
  end
  
  private

  def expire_cache_for(place)
    Rails.logger.info("spot-app: expiring cache for place #{place.to_param}")
    expire_page(place_path(place.id))
    expire_page(place_path(place.to_param))
    expire_page(sitemap_path(:format => :xml))
    expire_cache(place_path(place.id))
    expire_cache(place_path(place.to_param))
    expire_cache(sitemap_path(:format => :xml))
  end
  
end