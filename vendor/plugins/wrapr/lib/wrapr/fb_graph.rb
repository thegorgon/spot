module Wrapr
  module FbGraph
    def self.config
      @config ||= Wrapr::Config.init('fb_graph')
    end    
  end
end