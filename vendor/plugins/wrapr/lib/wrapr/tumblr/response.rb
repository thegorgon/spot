module Wrapr
  module Tumblr
    class Response < Wrapr::Response
      include Enumerable
      attr_accessor :items, :start, :total, :page_size
          
      def parse_response(xml)
        page_meta = xml.at("posts") || {}
        self.items = xml.css("posts post").collect do |post|
          object_class = "Wrapr::Tumblr::#{post['type'].classify}".constantize rescue nil
          if object_class
            object = object_class.new
            object.send(:parse_xml_node, post)
            object
          end
        end
        self.start = page_meta["start"].to_i
        self.total = page_meta["total"].to_i
        self.page_size = items.count
      end
      
      def page
        page_size > 0 ? (start / page_size).floor + 1 : 1
      end
    
      def next_page
        (total - start) > page_size ? page + 1 : nil
      end
    
      def previous_page
        page > 1 ? page - 1 : nil
      end
    
      [:size, :count, :length].each do |m|
        define_method m do
          @items.send(m)
        end
      end    
    
      def each(&block)
        items.each(&block)
      end
    end
  end
end