module Wrapr
  module Foursquare
    class Location < Wrapr::Model
      acts_as_model :address, :cross_street, :city, :state, :postal_code, :country, :lat, :lng    
    
      def full_address
        "#{address} #{city}, #{state} #{postal_code}"
      end
    end
  end
end