module Wrapr
  module Yelp
    class Response < Wrapr::Response
      def parse_response(parsed)
        if parsed["error"]
          self.status = 500
        else
          self.payload = parsed
        end
      end
    end
  end
end