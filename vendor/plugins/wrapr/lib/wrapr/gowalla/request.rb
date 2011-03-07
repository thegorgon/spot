module Wrapr
  module Gowalla
    class Request < Wrapr::Request

      header 'Accept', Mime::JSON.to_s
      header 'Content-Type', Mime::JSON.to_s
      header 'X-Gowalla-API-Key', lambda { Gowalla.config.api_key }

      def self.base_url(ssl=true)
        "#{ssl ? 'https' : 'http'}://api.gowalla.com"
      end      
      
    end
  end
end