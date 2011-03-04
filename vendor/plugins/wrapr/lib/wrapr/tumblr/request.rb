module Wrapr
  module Tumblr
    class Request < Wrapr::Request
      def self.base_url(ssl=true)
        "#{ssl ? 'https' : 'http'}://#{Tumblr.config.account}.tumblr.com"
      end

      def self.response_class
        Wrapr::Tumblr::Response
      end
      
      def sanitize(params)
        super(params).merge( :email => Tumblr.config.email, 
                             :password => Tumblr.config.password )
        
      end
      
    end
  end
end