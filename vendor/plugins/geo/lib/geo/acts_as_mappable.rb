module Geo
  # Contains the class method acts_as_mappable targeted to be mixed into ActiveRecord.
  # When mixed in, augments find services such that they provide distance calculation
  # query services.
  module ActsAsMappable 
    # Mix below class methods into ActiveRecord.
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    # Class method to mix into active record.
    module ClassMethods # :nodoc:
      # Class method to bring distance query support into ActiveRecord models.  By default
      # uses :miles for distance units and performs calculations based upon the Haversine
      # (sphere) formula.  These can be changed by setting GeoKit::default_units and
      # GeoKit::default_formula.  Also, by default, uses lat, lng, and distance for respective
      # column names.  All of these can be overridden using the :default_units, :default_formula,
      # :lat_column_name, :lng_column_name, and :distance_column_name hash keys.
      # 
      # Can also use to auto-geocode a specific column on create. Syntax;
      #   
      #   acts_as_mappable :auto_geocode=>true
      # 
      # By default, it tries to geocode the "address" field. Or, for more customized behavior:
      #   
      #   acts_as_mappable :auto_geocode=>{:field=>:address,:error_message=>'bad address'}
      #   
      # In both cases, it creates a before_validation_on_create callback to geocode the given column.
      # For anything more customized, we recommend you forgo the auto_geocode option
      # and create your own AR callback to handle geocoding.
      def acts_as_mappable(options = {})
        # Mix in the module, but ensure to do so just once.
        return if self.included_modules.include?(::Geo::ActsAsMappable::InstanceMethods)
        send :include, ::Geo::ActsAsMappable::InstanceMethods
        # include the Mappable module.
        send :include, ::Geo::Mappable
        
        # Handle class variables.
        cattr_accessor :mappable_options
        self.mappable_options = { :distance_column_name => 'distance', 
                                  :default_units => ::Geo.default_units, 
                                  :default_formula => ::Geo.default_formula,
                                  :lat_column_name => 'lat',
                                  :lng_column_name => 'lng' }.merge(options)                                          
      end
    end
  
    module InstanceMethods #:nodoc:    
      # Mix class methods into module.
      def self.included(base) # :nodoc:
        base.extend SingletonMethods
      end
      
      # Class singleton methods to mix into ActiveRecord.
      module SingletonMethods # :nodoc:
        def within(distance, options={})
          origin = Geo::LatLng.normalize(options[:origin])
          units = options[:units] || mappable_options[:default_units]
          sql =  distance_sql(origin, units)
          select("#{table_name}.*, #{sql} AS distance").where("#{sql} <= #{distance}")
        end
        
        def beyond(distance, options={})
          origin = Geo::LatLng.normalize(options[:origin])
          units = options[:units] || mappable_options[:default_units]
          sql =  distance_sql(origin, units)
          select("#{table_name}.*, #{sql} AS distance").where("#{sql} >= #{distance}")
        end
        
        def in_range(range, options={})
          beyond(range.min, options).within(range.max, options)
        end
                
        def qualified_lat_column_name
          "#{table_name}.#{mappable_options[:lat_column_name]}"
        end
        
        def qualified_lng_column_name
          "#{table_name}.#{mappable_options[:lng_column_name]}"
        end
        
        # ================
        # = Distance SQL =
        # ================
        
        # Returns the distance SQL using the proper units and formula
        def distance_sql(origin, units=nil, formula=nil)
          units ||= mappable_options[:default_units]
          formula ||= mappable_options[:default_formula]
          case formula
          when :sphere
            sql = sphere_distance_sql(origin, units)
          when :flat
            sql = flat_distance_sql(origin, units)
          end
          sql
        end   
        
        # Returns the distance SQL using the spherical world formula (Haversine).  The SQL is tuned
        # to the database in use.
        def sphere_distance_sql(origin, units)
          lat = deg2rad(origin.lat)
          lng = deg2rad(origin.lng)
          multiplier = units_sphere_multiplier(units)
          case connection.adapter_name.downcase
          when "mysql", "mysql2"
            sql=<<-SQL_END 
                  (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
                  COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
                  SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
                  SQL_END
          when "postgresql"
            sql=<<-SQL_END 
                  (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
                  COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
                  SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
                  SQL_END
          else
            sql = "unhandled #{connection.adapter_name.downcase} adapter"
          end        
        end
        
        # Returns the distance SQL using the flat-world formula (Phythagorean Theory).  The SQL is tuned
        # to the database in use.
        def flat_distance_sql(origin, units)
          lat_degree_units = units_per_latitude_degree(units)
          lng_degree_units = units_per_longitude_degree(origin.lat, units)
          case connection.adapter_name.downcase
          when "mysql"
            sql=<<-SQL_END
                  SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
                  POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
                  SQL_END
          when "postgresql"
            sql=<<-SQL_END
                  SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
                  POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
                  SQL_END
          else
            sql = "unhandled #{connection.adapter_name.downcase} adapter"
          end
        end 
      end
    end
  end
end  