module Wrapr
  module Gowalla
    class Response < Wrapr::Response
      attr_accessor :total_results, :locality, :per_page, :current_page, :groups, :total_pages
      
      def parse_response(json)
        [:total_results, :locality, :per_page, :current_page, :groups, :total_pages].each do |key|
          value = json.delete(key.to_s)
          self.send("#{key}=", value) if value
        end
        self.payload = json
      end
    end
  end
end