module Wrapr
  module Foursquare
    class Request < Wrapr::Request
      def self.base_url(ssl=true)
        "#{ssl ? 'https' : 'http'}://api.foursquare.com/v2"
      end      
      
      def self.response_class
        Wrapr::Tumblr::Response
      end
      
      def sanitize(params)
        super(params).merge( :client_id => Foursquare.config.client_id, 
                             :client_secret => Foursquare.config.client_secret )
      end

    end
  end
end