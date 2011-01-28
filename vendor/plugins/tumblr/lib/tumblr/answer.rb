module Tumblr
  class Answer < Item
    attr_accessor :question, :answer
    
    private
    
    def parse_xml_node(node)
      super(node)
      self.caption = node.css('question').first.try(:content)
      self.source = node.css('answer').first.try(:content)
      self
    end
  end
end