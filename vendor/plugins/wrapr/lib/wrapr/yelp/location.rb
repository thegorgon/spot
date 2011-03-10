module Wrapr
  module Yelp
    class Location < Wrapr::Model
      property :latitude, :longitude, :in => :coordinate
      property :address_lines, :as => :display_address
      property :address, :city, :country_code, :cross_streets, :geo_accuracy, 
                :neighborhoods, :postal_code, :state_code
    end
  end
end