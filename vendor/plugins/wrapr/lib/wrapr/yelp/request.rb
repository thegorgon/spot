module Wrapr
  module Yelp
    class Request < Wrapr::Request
      param :output, :json
      endpoint_url 'http://api.yelp.com/v2'
      ignore_ssl
      
      oauth_options lambda { { :key => Yelp.config.consumer_key,
                               :secret => Yelp.config.consumer_secret } }

      oauth_token lambda { { :key => Yelp.config.oauth_token,
                             :secret => Yelp.config.oauth_token_secret } }      
    end
  end
end