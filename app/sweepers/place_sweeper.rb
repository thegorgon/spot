class PlaceSweeper < ActionController::Caching::Sweeper
  observe Place

  def after_update(place)
    expire_cache_for(place)
  end
  
  def after_create(place)
    expire_cache_for(place)
  end
  
  private

  def expire_cache_for(place)
    expire_page(:controller=>"site/places",:action=>"show",:id => place.id)
    expire_page(:controller=>"site/sitemaps", :action=>"show")
    expire_cache(:controller=>"site/places",:action=>"show",:id => place.id)
    expire_cache(:controller=>"site/sitemaps", :action=>"show")
  end
  
end