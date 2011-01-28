module Tumblr
  class Link < Item
    attr_accessor :text, :url
    
    private
    
    def parse_xml_node(node)
      super(node)
      self.text = node.css('link-text').first.try(:content)
      self.source = node.css('link-url').first.try(:content)
      self
    end
  end
end