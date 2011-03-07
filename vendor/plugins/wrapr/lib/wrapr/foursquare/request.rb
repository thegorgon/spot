module Wrapr
  module Foursquare
    class Request < Wrapr::Request
      param :client_id, lambda { Foursquare.config.client_id }
      param :client_secret, lambda { Foursquare.config.client_secret }
      
      def self.base_url(ssl=true)
        "#{ssl ? 'https' : 'http'}://api.foursquare.com/v2"
      end      
      
    end
  end
end