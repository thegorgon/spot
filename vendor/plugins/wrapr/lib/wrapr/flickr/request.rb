module Wrapr
  module Flickr
    class Request < Wrapr::Request
      ENDPOINT = "http://api.flickr.com/services/rest"
      SSL_ENDPOINT = "https://secure.flickr.com/services/rest"
      
      param :format, 'json'
      param :api_key, lambda { Flickr.config.api_key }
      path_param :method, lambda { |path| "flickr.#{path.gsub(/^flickr\./, '')}" }
      
      def self.base_url(ssl=true)
        ssl ? SSL_ENDPOINT : ENDPOINT
      end
      
    end
  end
end