module Wrapr
  module Foursquare
    class Response < Wrapr::Response      
      
      def parse_response(parsed)
        self.status = parsed['meta']['code']
        self.body = parsed['response']
      end

    end
  end
end