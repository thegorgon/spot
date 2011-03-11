module Wrapr
  module Yelp
    class Response < Wrapr::Response
      
      def parse_response(parsed)
        if parsed["error"]
          self.status = 500
          self.error_message = parsed["error"]["text"]
          self.error_type = parsed["error"]["id"]
        else
          self.payload = parsed
        end
      end
    end
  end
end