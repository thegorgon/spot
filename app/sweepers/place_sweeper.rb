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

  def expire_cache_for(place)
    Rails.logger.info("spot-app: expiring cache for place #{place.to_param}")
    [ {:controller => "site/places", :action=>"show", :id => place.id}, 
      {:controller => "site/places", :action=>"show", :id => place.to_param}, 
      {:controller => "site/sitemaps", :action=>"show"} ].each do |action|
        Rails.logger.info("spot-app: expiring cache #{ActionCachePath.new(self, action, false).path}")
        expire_action(action)      
      end
  end
  
end