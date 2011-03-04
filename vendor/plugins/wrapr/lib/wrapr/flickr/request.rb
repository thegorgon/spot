module Wrapr
  module Flickr
    class Request < Wrapr::Request
      ENDPOINT = "http://api.flickr.com/services/rest"
      SSL_ENDPOINT = "https://secure.flickr.com/services/rest"
      
      def self.base_url(ssl=true)
        ssl ? SSL_ENDPOINT : ENDPOINT
      end
      
      def self.response_class
        Wrapr::Flickr::Response
      end
      
      def sanitize(params)
        params[:format] = 'json'
        params[:api_key] = Flickr.config.api_key
        params[:method] = "flickr.#{@path.gsub(/^flickr\./, '')}"
        @path = ""
        params
      end
    end
  end
end