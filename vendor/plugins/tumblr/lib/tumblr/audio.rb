module Tumblr
  class Audio < Item
    attr_accessor :caption, :player
  
    private
    
    def parse_xml_node(node)
      super(node)
      self.caption = node.css('audio-caption').first.try(:content)
      self.source = node.css('audio-player').first.try(:content)
      self
    end
  end
end