module Wrapr
  module Tumblr
    class Request < Wrapr::Request
      param :email, lambda { Tumblr.config.email }
      param :password, lambda { Tumblr.config.password }
      
      def self.base_url(ssl=true)
        "#{ssl ? 'https' : 'http'}://#{Tumblr.config.account}.tumblr.com"
      end
      
    end
  end
end