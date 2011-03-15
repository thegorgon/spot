require 'external_place'
class YelpPlace < ActiveRecord::Base
  external_place :id => :yelp_id, :wrapr => Wrapr::Yelp::Business, :alias => { :region => :state_code, :country => :country_code, :phone_number => :phone }
  
  serialize :categories, Array
  serialize :neighborhoods, Array
  
  def self.from_wrapr(wrapr)
    object = new
    object.name = wrapr.name
    object.phone = wrapr.phone
    object.address = wrapr.location.address
    object.city = wrapr.location.city
    object.state_code = wrapr.location.state_code
    object.country_code = wrapr.location.country_code
    object.postal_code = wrapr.location.postal_code
    object.cross_streets = wrapr.location.cross_streets
    object.display_address = wrapr.location.address_lines.join("\n")
    object.neighborhoods = wrapr.location.neighborhoods
    object.geo_accuracy = wrapr.location.geo_accuracy
    object.categories = wrapr.categories.to_a.collect { |c| c.name }
    object.lat = wrapr.location.latitude.to_f
    object.lng = wrapr.location.longitude.to_f
    object.yelp_id = wrapr.id
    object
  end
      
  def address_lines
    if city.present? && state_code.present? && (postal_code.present? || country_code.present?)
      second_line = "#{city}, #{state_code} #{[postal_code, country_code].join(' ')}" 
    else
      second_line = [city, state_code, postal_code, country_code].compact.join(', ')
    end    
    [address, second_line]
  end
  
end