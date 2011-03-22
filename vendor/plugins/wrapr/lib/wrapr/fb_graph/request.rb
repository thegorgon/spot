module Wrapr
  module FbGraph
    class Request < Wrapr::Request
      endpoint_url 'https://graph.facebook.com'

      param :client_id, lambda { FbGraph.config.client_id }
      param :client_secret, lambda { FbGraph.config.client_secret }
      param :access_token, lambda { |req| 
        req.input_params[:access_token] || req.options[:access_token] || FbGraph.config.oauth_token
      }
    end
  end
end