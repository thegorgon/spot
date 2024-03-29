# Load modules and classes needed to automatically mix in ActiveRecord and 
# ActionController helpers.  All other functionality must be explicitly 
# required.
require 'geo'
require 'geo/mappable'
require 'geo/lat_lng'
require 'geo/cleaner'
require 'geo/acts_as_mappable'
require 'geo/position'
require 'geo/rack/geo_headers'

# Automatically mix in distance finder support into ActiveRecord classes.
ActiveRecord::Base.send :include, Geo::ActsAsMappable
Rails.application.config.middleware.use Geo::Rack::GeoHeaders
