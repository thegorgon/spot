module Tumblr
  class Conversation < Item
    attr_accessor :title, :text, :lines
    
    class Line < Struct.new(:name, :label, :content); end

    private
    
    def self.parse_xml_node(node)
      super(node)
      self.title = node.css('conversation-title').first.try(:content)
      self.text = node.css('conversation-text').first.try(:content)
      self.lines = node.css("convesation line").collect do |line|
        Line.new(line["name"], line["label"], label.content)
      end
      self
    end
    
  end
end