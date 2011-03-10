module Wrapr
  module Foursquare
    class Request < Wrapr::Request
      endpoint_url 'http://api.foursquare.com/v2'

      param :client_id, lambda { Foursquare.config.client_id }
      param :client_secret, lambda { Foursquare.config.client_secret }
    end
  end
end