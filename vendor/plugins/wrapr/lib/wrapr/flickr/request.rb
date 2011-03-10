module Wrapr
  module Flickr
    class Request < Wrapr::Request      
      endpoint_url "http://api.flickr.com/services/rest"
      ssl_endpoint_url "https://secure.flickr.com/services/rest"      

      param :format, 'json'
      param :api_key, lambda { Flickr.config.api_key }

      path_param :method, lambda { |path| "flickr.#{path.gsub(/^flickr\./, '')}" }
    end
  end
end