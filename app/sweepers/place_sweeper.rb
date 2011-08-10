class PlaceSweeper < ActionController::Caching::Sweeper
  observe Place

  def after_update(place)
    Rails.logger.info "place-sweeper: after_update place #{place.to_param}"
    expire_cache_for(place)
  end
  
  def after_create(place)
    Rails.logger.info "place-sweeper: after_create place #{place.to_param}"
    expire_cache_for(place)
  end
  
  private

  def controller
    Thread.current[:controller]
  end

  def expire_cache_for(place)
    Rails.logger.info("spot: expiring cache for place #{place.to_param}")
    [ {:controller => "site/places", :action => "show", :id => place.id}, 
      {:controller => "site/places", :action => "show", :id => place.to_param}, 
      {:controller => "site/sitemaps", :action => "show"} ].each do |action|
      controller.send(:expire_action, action) if controller
    end
  end
  
end