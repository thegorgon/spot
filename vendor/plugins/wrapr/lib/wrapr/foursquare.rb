module Wrapr
  module Foursquare
    def self.config
      @config ||= Wrapr::Config.init('foursquare')
    end
  end
end