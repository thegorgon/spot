module Wrapr
  module Gowalla
    def self.config
      @config ||= Wrapr::Config.init('gowalla')
    end
  end
end