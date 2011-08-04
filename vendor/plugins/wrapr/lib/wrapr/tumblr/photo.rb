module Wrapr
  module Tumblr
    class Photo < Item
      attr_accessor :caption, :sizes
  
      class Size < Struct.new(:url, :max_width); end

      def max_size
        sizes.last
      end
      
      def min_size
        sizes.first
      end
      
      def title
        unless @title
          @title = ""
          words = caption.gsub(/\<[^\>]+?\>/, "").split(' ')
          words.each do |word|
            break if @title.length + word.length > 25
            @title << " #{word}"
          end
          @title = "#{@title.strip}..."
        end
        @title
      end

      private
    
      def parse_xml_node(node)
        super(node)
        self.caption = node.css('photo-caption').first.try(:content)
        self.sizes = node.css("photo-url").collect do |size|
          Size.new(size.content, size['max-width'].to_i)
        end
        self.sizes.sort! { |s1, s2| s1.max_width <=> s2.max_width }
        self
      end
    end
  end
end