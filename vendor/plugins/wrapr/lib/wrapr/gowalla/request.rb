module Wrapr
  module Gowalla
    class Request < Wrapr::Request
      endpoint_url 'http://api.gowalla.com'

      header 'Accept', Mime::JSON.to_s
      header 'Content-Type', Mime::JSON.to_s
      header 'X-Gowalla-API-Key', lambda { Gowalla.config.api_key }
      
    end
  end
end