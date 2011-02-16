module Geo
  class LatLng
    include Mappable
    
    attr_accessor :lat, :lng

    # Accepts latitude and longitude or instantiates an empty instance
    # if lat and lng are not provided. Converted to floats if provided
    def initialize(lat=nil, lng=nil)
      lat = lat.to_f if lat && !lat.is_a?(Numeric)
      lng = lng.to_f if lng && !lng.is_a?(Numeric)
      @lat = lat
      @lng = lng
    end
    
    # A *class* method to take anything which can be inferred as a point and generate
    # a LatLng from it. You should use this anything you're not sure what the input is,
    # and want to deal with it as a LatLng if at all possible. Can take:
    #  1) two arguments (lat,lng)
    #  2) a string in the format "37.1234,-129.1234" or "37.1234 -129.1234"
    #  3) a string which can be geocoded on the fly
    #  4) an array in the format [37.1234,-129.1234]
    #  5) a LatLng or GeoLoc (which is just passed through as-is)
    #  6) anything which responds to *to_lat_lng* -- the return value will be normalized and returned
    def self.normalize(*args)
      # Handle any possible input type
      options = args.extract_options!
      options.symbolize_keys! if options.respond_to?(:symbolize_keys!)
      thing = (options[:origin] || options[:ll])
      thing ||= [options[:lat], options[:lng]] if options[:lat] && options[:lng]
      thing ||= args.first if args.first.is_a?(String) || (args.first.is_a?(Array) && args.first.size == 2) || args.first.is_a?(LatLng) || args.first.respond_to?(:to_lat_lng)
      thing ||= args
      # Parse the damn thing
      if thing.is_a?(String) && match = thing.match(/\s*(\-?\d+\.?\d*)[, ] ?(\-?\d+\.?\d*)\s*$/)
        new(match[1], match[2])
      elsif thing.is_a?(Array) && thing.size == 2
        new(thing[0], thing[1])
      elsif thing.is_a?(LatLng)
        thing
      elsif thing.respond_to?(:to_lat_lng)
        normalize(thing.to_lat_lng)
      else
        throw ArgumentError.new("#{thing.inspect} <#{thing.class}> cannot be normalized to a LatLng.") unless options[:quiet]
      end
    end

    # Latitude attribute setter; stored as a float.
    def lat=(lat)
      @lat = lat.to_f if lat
    end

    # Longitude attribute setter; stored as a float;
    def lng=(lng)
      @lng=lng.to_f if lng
    end

    # Returns the lat and lng attributes as a comma-separated string.
    def ll
      "#{lat},#{lng}"
    end

    #returns a string with comma-separated lat,lng values
    def to_s
      ll
    end

    #returns a two-element array
    def to_a
      [lat,lng]
    end
    
    # Returns all important fields as key-value pairs
    def to_hash
      {}.tap do |hash|
        [:lat, :lng, :ll].each do |s| 
          hash[s] = self.send(s)
        end
      end
    end
    
    # Returns true if the candidate object is logically equal.  Logical equivalence
    # is true if the lat and lng attributes are the same for both objects.
    def ==(other)
      other.is_a?(LatLng) ? self.lat == other.lat && self.lng == other.lng : false
    end
    
    # Returns an inspectable representation of the instance.
    def inspect
      string = "#<#{self.class} "
      attrs = []
      to_hash.each do |key, value|
        attrs << "#{key}: #{value.inspect}"
      end
      string << attrs.join(", ") 
      string << ">"
    end
    
  end
end