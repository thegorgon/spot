require 'external_place'
class GowallaPlace < ActiveRecord::Base
  external_place :id => :gowalla_id, :wrapr => Wrapr::Gowalla::Spot, :alias => { :city => :locality, :country => :iso3166 }

  serialize :categories, Array
  
  def self.from_wrapr(wrapr)
    object = new
    object.name = wrapr.name
    object.street_address = wrapr.address.street_address
    object.region = wrapr.address.region
    object.locality = wrapr.address.locality
    object.iso3166 = wrapr.address.iso3166
    object.lat = wrapr.lat.to_f
    object.lng = wrapr.lng.to_f
    object.radius_meters = wrapr.radius_meters.to_i
    object.phone_number = wrapr.phone_number
    object.categories = wrapr.categories.collect { |c| c.name }
    object.gowalla_id = wrapr.id
    object.foursquare_id = wrapr.foursquare_id
    object
  end
  
  def address_lines
    if region.present? && locality.present? && iso3166.present?
      second_line = "#{locality}, #{region} #{iso3166}" 
    else
      second_line = [locality, region, iso3166].compact.join(', ')
    end    
    [street_address, second_line]
  end
  
end