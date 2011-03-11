module Wrapr
  module FbGraph
    class Response < Wrapr::Response

      def parse_response(parsed)
        self.payload = parsed
        if parsed["error"]
          self.status = 500
          self.error_message = parsed["error"]["message"]
          self.error_type = parsed["error"]["type"]
          self.payload = parsed
        end
      end
    end
  end
end