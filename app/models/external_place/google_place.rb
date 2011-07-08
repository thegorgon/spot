class ExternalPlace::GooglePlace < ActiveRecord::Base
  external_place :id => :cid, :wrapr => Google::Place
  
  def self.from_wrapr(wrapr)
    object = new
    object.cid = wrapr.cid
    object.name = wrapr.name
    object.listing_type = wrapr.listing_type
    object.street_address = wrapr.street_address
    object.city = wrapr.city
    object.region = wrapr.region
    object.country = wrapr.country
    object.address = wrapr.address_lines.join("\n") if wrapr.address_lines.respond_to?(:join)
    object.phone_number = wrapr.phone_number
    object.lat = wrapr.lat.to_f
    object.lng = wrapr.lng.to_f    
    object
  end
  
  def address_lines
    (address || "").split("\n")
  end
  
end