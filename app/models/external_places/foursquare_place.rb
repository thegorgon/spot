require 'external_place'
class FoursquarePlace < ActiveRecord::Base
  external_place :id => :foursquare_id, :wrapr => Wrapr::Foursquare::Venue, :alias => { :region => :state, :phone_number => :phone }

  def self.from_wrapr(wrapr)
    object = new
    object.name = wrapr.name
    object.categories = wrapr.categories.to_a.collect { |c| c.name }
    object.address = wrapr.location.address
    object.cross_street = wrapr.location.cross_street
    object.city = wrapr.location.city
    object.state = wrapr.location.state
    object.postal_code = wrapr.location.postal_code
    object.country = wrapr.location.country
    object.lat = wrapr.location.lat.to_f
    object.lng = wrapr.location.lng.to_f    
    object.phone = wrapr.phone
    object.twitter = wrapr.phone
    object.foursquare_id = wrapr.id
    object
  end

  def address_lines
    if city.present? && state.present? && (postal_code.present? || country.present?)
      second_line = "#{city}, #{state} #{[postal_code, country].join(' ')}" 
    else
      second_line = [city, state, postal_code, country].compact.join(', ')
    end    
    [address, second_line]
  end
  
end