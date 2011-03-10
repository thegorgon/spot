require 'external_place'
class FacebookPlace < ActiveRecord::Base
  external_place :id => :facebook_id, :wrapr => Wrapr::FbGraph::Place

  def self.from_wrapr(wrapr)
    object = new
    object.name = wrapr.name
    object.category = wrapr.category
    object.street = wrapr.street
    object.city = wrapr.city
    object.state = wrapr.state
    object.country = wrapr.country
    object.zip = wrapr.zip
    object.lat = wrapr.lat.to_f
    object.lng = wrapr.lng.to_f    
    object.facebook_id = wrapr.id
    object
  end
    
  def address_lines
    if city.present? && state.present? && (zip.present? || country.present?)
      second_line = "#{city}, #{state} #{[zip, country].join(' ')}" 
    else
      second_line = [city, state, zip, country].compact.join(', ')
    end    
    [street, second_line]
  end
  
end