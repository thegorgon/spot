module Wrapr
  module Tumblr
    class << self
      def config
        @config ||= Wrapr::Config.init('tumblr')
      end  
    end
  end
end