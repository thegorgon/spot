module Geo
  class Loc < LatLng
    # Location attributes.  Full address is a concatenation of all values.  For example:
    attr_accessor :street_address, :city, :region, :zip, :country, :full_address
    attr_reader :street_number, :street_name
    
    def initialize(*args)
      lat_lng = LatLng.normalize(*args) rescue nil
      params = args.extract_options!
      if lat_lng
        self.lat = lat_lng.lat
        self.lng = lat_lng.lng
      end
      [:street_address, :city, :region, :zip, :country, :full_address].each do |k|
        self.send("#{k}=", params[k])
      end
    end
    
    # Extracts the street number from the street address if the street address
    # has a value.
    def street_number
      @street_number ||= street_address[/(\d*)/] if street_address
    end

    # Returns the street name portion of the street address.
    def street_name
       @street_name ||= street_address[street_number.length, street_address.length].strip if street_address
    end
    
    # Sets the city after capitalizing each word within the city name.
    def city=(city)
      @city = city.titleize if city
    end

    # Sets the street address after capitalizing each word within the street address and clearing parts.
    def street_address=(address)
      @street_name = @street_name = nil
      @street_address = address.titleize if address
    end
    
    # Returns all important fields as key-value pairs
    def to_hash
      {}.tap do |hash|
        [:lat, :lng, :country, :city, :region, :zip, :street_address, :full_address, :ll].each do |s| 
          hash[s] = self.send(s)
        end
      end
    end
    
    # Returns a comma-delimited string consisting of the street address, city, region,
    # zip, and country code.  Only includes those attributes that are non-blank.
    def to_geocodeable_s
      a = [street_address, city, region, zip, country].compact
      a.delete_if { |e| !e || e == '' }
      a.join(', ')      
    end    
  end
end