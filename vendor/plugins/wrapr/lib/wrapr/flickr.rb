module Wrapr
  module Flickr
    def self.config
      @config ||= Wrapr::Config.init('flickr')
    end    
  end
end