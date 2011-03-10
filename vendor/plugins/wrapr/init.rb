require 'wrapr'
require 'wrapr/config'
require 'wrapr/model'
require 'wrapr/request'
require 'wrapr/response'
require 'wrapr/foursquare'

require 'wrapr/foursquare/response'
require 'wrapr/foursquare/request'
require 'wrapr/foursquare/location'
require 'wrapr/foursquare/category'
require 'wrapr/foursquare/venue'

require 'wrapr/tumblr'
require 'wrapr/tumblr/item'
require 'wrapr/tumblr/answer'
require 'wrapr/tumblr/audio'
require 'wrapr/tumblr/conversation'
require 'wrapr/tumblr/item'
require 'wrapr/tumblr/link'
require 'wrapr/tumblr/photo'
require 'wrapr/tumblr/quote'
require 'wrapr/tumblr/regular'
require 'wrapr/tumblr/video'

require 'wrapr/flickr'
require 'wrapr/flickr/photo'

require 'oauth/request_proxy/curl'

ActionView::Base.send(:include, Google::Helper)