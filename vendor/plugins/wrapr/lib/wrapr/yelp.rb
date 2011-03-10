module Wrapr
  module Yelp
    def self.config
      @config ||= Wrapr::Config.init('yelp')
    end    
  end
end