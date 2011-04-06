class MobileApp < ActiveRecord::Base
  STORES = ["android", "itunes"]
  
  validates :location, :presence => true
  validates :name, :presence => true
  validates :store_id, :presence => true
  validates :store, :presence => true, :inclusion => STORES
  
  def self.url_for(location, store=nil)    
    where(:location => location, :store => store || "itunes", :live => true).first.try(:url)
  end
  
  def self.country_code(request)
    @geo_ip ||= GeoIP.new('db/GeoIP.dat')
    @geo_ip.country(request.remote_ip).country_code2
  end
  
  def country
    location.split('-', 2).last.downcase
  end
  
  def live!
    update_attribute(:live, true)
  end
  
  def die!
    update_attribute(:live, false)
  end
  
  def url
    if store == "itunes"
      "http://itunes.apple.com/#{country}/app/#{name.parameterize}/id#{store_id}"
    end
  end
end