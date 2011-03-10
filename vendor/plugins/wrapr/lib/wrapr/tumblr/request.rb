module Wrapr
  module Tumblr
    class Request < Wrapr::Request
      endpoint_url lambda { "http://#{Tumblr.config.account}.tumblr.com" }
      
      param :email, lambda { Tumblr.config.email }
      param :password, lambda { Tumblr.config.password }      
    end
  end
end