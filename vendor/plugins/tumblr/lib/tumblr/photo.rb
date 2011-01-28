module Tumblr
  class Photo < Item
    attr_accessor :caption, :sizes
  
    class Size < Struct.new(:url, :max_width); end

    def max_size
      sizes.last
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