module Wrapr
  class Request
    module Options
      def self.included(base)
        base.send(:extend, ClassMethods)
        base.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def response_class
          to_s.gsub("Request", "Response").constantize
        end

        def base_uri(ssl=true)
          url = (@_base_urls ||= {})[ssl ? :ssl : :normal]
          url = url.kind_of?(Proc) ? url.call : url
          if ssl && url.blank?
            url = @_base_urls[:normal]
            url = url.kind_of?(Proc) ? url.call : url
            url.gsub!('http:', 'https:') if use_ssl?
          end
          URI.parse(url) rescue nil
        end
        
        def header(name, value)
          (@_headers ||= {})[name] = value
        end
        
        def ignore_ssl
          @_use_ssl = false
        end
        
        def use_ssl?
          @_use_ssl.nil? || @_use_ssl
        end

        def param(name, value)
          (@_params ||= {})[name] = value
        end

        def endpoint_url(value)
          (@_base_urls ||= {})[:normal] = value
        end

        def ssl_endpoint_url(value)
          (@_base_urls ||= {})[:ssl] = value
        end

        def path_param(name, value)
          @_path_param_key = name
          @_path_param_value = value 
        end
      end
      
      module InstanceMethods
        def populate_params(input)
          class_params = self.class.instance_variable_get("@_params") || {}
          params = input ? input.clone : {}
          class_params.each do |key, value|
            if value.kind_of?(Proc) && value.parameters.length == 1
              value = value.call(self)
            elsif value.kind_of?(Proc)
              value = value.call
            end
            params[key] ||= value
          end
          path_param_key = self.class.instance_variable_get("@_path_param_key")
          path_param_value = self.class.instance_variable_get("@_path_param_value")
          path_param_value = path_param_value.call(@path) if path_param_value.kind_of?(Proc)
          if path_param_key.present?
            @path = ''
            params[path_param_key] ||= path_param_value
          end
          params.delete_if { |key, value| value.blank? }
          params
        end

        def populate_headers(input)
          class_headers = self.class.instance_variable_get("@_headers") || {}
          headers = input ? input.clone : {}
          class_headers.each do |key, value|
            value = value.call if value.kind_of?(Proc)
            headers[key] ||= value
          end
          headers
        end
      end      
    end
  end
end