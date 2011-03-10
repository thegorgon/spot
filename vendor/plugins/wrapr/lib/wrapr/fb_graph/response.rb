module Wrapr
  module FbGraph
    class Response < Wrapr::Response
      def parse_response(parsed)
        self.payload = parsed
      end
    end
  end
end