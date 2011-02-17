module Geo
  module Mappable
    # Mix below class methods into the includer.
    def self.included(receiver) # :nodoc:
      receiver.extend ClassMethods
    end   
    
    module ClassMethods #:nodoc:
      # Returns the distance between two points.  The from and to parameters are
      # required to have lat and lng attributes.  Valid options are:
      # :units - valid values are :miles or :kms (Geo.default_units is the default)
      # :formula - valid values are :flat or :sphere (Geo.default_formula is the default)
      def distance_between(from, to, options={})
        from = Geo::LatLng.normalize!(from)
        to = Geo::LatLng.normalize!(to)
        if from == to # fixes a "zero-distance" bug
          0.0
        else
          units = options[:units] || Geo::default_units
          formula = options[:formula] || Geo::default_formula
          case formula
          when :sphere          
            units_sphere_multiplier(units) * 
                Math.acos(Math.sin(deg2rad(from.lat)) * Math.sin(deg2rad(to.lat)) + 
                Math.cos(deg2rad(from.lat)) * Math.cos(deg2rad(to.lat)) * 
                Math.cos(deg2rad(to.lng) - deg2rad(from.lng)))   
          when :flat
            Math.sqrt((units_per_latitude_degree(units) * (from.lat - to.lat))**2 + 
                (units_per_longitude_degree(from.lat, units)*(from.lng - to.lng))**2)
          end
        end
      end

      # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
      # from the first point to the second point. Typicaly, the instance methods will be used 
      # instead of this method.
      def heading_between(from, to)
        from = Geo::LatLng.normalize!(from)
        to = Geo::LatLng.normalize!(to)

        d_lng = deg2rad(to.lng - from.lng)
        from_lat = deg2rad(from.lat)
        to_lat = deg2rad(to.lat) 
        y = Math.sin(d_lng) * Math.cos(to_lat)
        x = Math.cos(from_lat) * Math.sin(to_lat) - Math.sin(from_lat) * Math.cos(to_lat) * Math.cos(d_lng)
        heading = to_heading(Math.atan2(y,x))
      end

      # Given a start point, distance, and heading (in degrees), provides
      # an endpoint. Returns a LatLng instance. Typically, the instance method
      # will be used instead of this method.
      def endpoint(start, heading, distance, options={})
        units = options[:units] || Geo::default_units
        radius = units == :miles ? Geo::EARTH_RADIUS_IN_MILES : Geo::EARTH_RADIUS_IN_KMS
        start = Geo::LatLng.normalize!(start)        
        lat = deg2rad(start.lat)
        lng = deg2rad(start.lng)
        heading = deg2rad(heading)
        distance = distance.to_f

        end_lat = Math.asin(Math.sin(lat) * Math.cos(distance/radius) +
                          Math.cos(lat) * Math.sin(distance/radius) * Math.cos(heading))

        end_lng = lng+Math.atan2(Math.sin(heading) * Math.sin(distance/radius) * Math.cos(lat),
                               Math.cos(distance/radius) - Math.sin(lat) * Math.sin(end_lat))

        Geo::LatLng.new(rad2deg(end_lat), rad2deg(end_lng))
      end

      # Returns the midpoint, given two points. Returns a LatLng. 
      # Typically, the instance method will be used instead of this method.
      # Valid option:
      #   :units - valid values are :miles or :kms (:miles is the default)
      def midpoint_between(from, to, options={})
        from = Geo::LatLng.normalize!(from)

        units = options[:units] || Geo::default_units

        heading = from.heading_to(to)
        distance = from.distance_to(to,options)
        midpoint = from.endpoint(heading,distance/2, options)
      end

      protected

      def deg2rad(degrees)
        degrees.to_f / 180.0 * Math::PI
      end

      def rad2deg(rad)
        rad.to_f * 180.0 / Math::PI 
      end

      def to_heading(rad)
        (rad2deg(rad)+360)%360
      end

      # Returns the multiplier used to obtain the correct distance units.
      def units_sphere_multiplier(units)
        units == :miles ? Geo::EARTH_RADIUS_IN_MILES : Geo::EARTH_RADIUS_IN_KMS
      end

      # Returns the number of units per latitude degree.
      def units_per_latitude_degree(units)
        units == :miles ? Geo::MILES_PER_LATITUDE_DEGREE : Geo::KMS_PER_LATITUDE_DEGREE
      end

      # Returns the number units per longitude degree.
      def units_per_longitude_degree(lat, units)
        miles_per_longitude_degree = (Geo::LATITUDE_DEGREES * Math.cos(lat * Geo::PI_DIV_RAD)).abs
        units == :miles ? miles_per_longitude_degree : miles_per_longitude_degree * Geo::KMS_PER_MILE
      end  
    end

    # -----------------------------------------------------------------------------------------------
    # Instance methods below here
    # -----------------------------------------------------------------------------------------------

    # Extracts a LatLng instance. Use with models that have a lat and lng
    def to_lat_lng
      if is_a?(Geo::LatLng)
        self
      elsif self.class.respond_to?(:mappable_options)
        LatLng.new(send(self.class.mappable_options[:lat_column_name]), send(self.class.mappable_options[:lng_column_name]))
      end
    end

    # Returns the distance from another point.  The other point parameter is
    # required to have lat and lng attributes.  Valid options are:
    # :units - valid values are :miles or :kms (:miles is the default)
    # :formula - valid values are :flat or :sphere (:sphere is the default)
    def distance_to(other, options={})
      self.class.distance_between(self, other, options)
    end  
    alias distance_from distance_to

    # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
    # to the given point. The given point can be a LatLng or a string to be Geocoded 
    def heading_to(other)
      self.class.heading_between(self,other)
    end

    # Returns heading in degrees (0 is north, 90 is east, 180 is south, etc)
    # FROM the given point. The given point can be a LatLng or a string to be Geocoded 
    def heading_from(other)
      self.class.heading_between(other,self)
    end

    # Returns the endpoint, given a heading (in degrees) and distance.  
    # Valid option:
    # :units - valid values are :miles or :kms (:miles is the default)
    def endpoint(heading,distance,options={})
      self.class.endpoint(self,heading,distance,options)  
    end

    # Returns the midpoint, given another point on the map.  
    # Valid option:
    # :units - valid values are :miles or :kms (:miles is the default)    
    def midpoint_to(other, options={})
      self.class.midpoint_between(self,other,options)
    end

  end    
end