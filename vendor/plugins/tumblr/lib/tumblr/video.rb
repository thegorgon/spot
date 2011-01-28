module Tumblr
  class Video < Item
    attr_accessor :caption, :source, :player

    private
    
    def parse_xml_node(node)
      super(node)
      self.caption = node.css('video-title').first.try(:content)
      self.source = node.css('video-text').first.try(:content)
      self.player = node.css('video-player').first.try(:content)
      self
    end
  end
end