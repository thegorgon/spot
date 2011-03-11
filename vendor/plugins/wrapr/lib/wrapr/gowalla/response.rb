module Wrapr
  module Gowalla
    class Response < Wrapr::Response
      attr_accessor :total_results, :locality, :per_page, :current_page, :groups, :total_pages
      
      def parse_response(parsed)
        if parsed["error"]
          self.status = 500
          self.error_message = parsed["error"]
          self.payload = parsed
        else
          [:total_results, :locality, :per_page, :current_page, :groups, :total_pages].each do |key|
            value = parsed.delete(key.to_s)
            self.send("#{key}=", value) if value
          end
          self.payload = parsed
        end
      end
    end
  end
end