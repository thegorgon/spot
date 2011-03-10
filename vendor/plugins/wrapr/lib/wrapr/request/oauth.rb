module Wrapr
  class Request
    module Oauth
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end
      
      module ClassMethods
        def oauth_options(options)
          @_oauth_options = options
        end
        
        def oauth_consumer
          @_oauth_options = @_oauth_options.call if @_oauth_options.kind_of?(Proc)
          if @_oauth_options && @_oauth_options[:key].present? && @_oauth_options[:secret].present?
            @oauth_consumer ||= ::OAuth::Consumer.new(@_oauth_options[:key], @_oauth_options[:secret], {
              :site   =>  @_oauth_options[:site] || "http://#{base_uri(true).host}"
            })
          end
        end
        
        def oauth_token(options)
          @_oauth_token = options
        end
        
        def oauth_access_token
          @_oauth_token = @_oauth_token.call if @_oauth_token.kind_of?(Proc)
          if oauth_consumer && @_oauth_token && @_oauth_token[:key].present? && @_oauth_token[:secret].present?
            @access_token ||= ::OAuth::AccessToken.new(oauth_consumer, @_oauth_token[:key], @_oauth_token[:secret])
          end
        end
        
        def oauth_helper(request, options={})
          if oauth_consumer && oauth_access_token
            oauth_consumer.options[:http_method] = options[:http_method]
            options.merge!(:consumer => oauth_consumer, :token => oauth_access_token, :scheme => 'header')
            ::OAuth::Client::Helper.new(request, options)
          end
        end
      end
      
      module InstanceMethods
        def oauthify(curb)
          if helper = self.class.oauth_helper(curb, :uri => curb.url, :http_method => @method.upcase)
            curb.headers["Authorization"] = helper.header
          end
          curb
        end        
      end
    end
  end
end