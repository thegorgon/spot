module Wrapr
  class Request
    module RequestMethods
      def self.included(base)
        base.send(:extend, ClassMethods)
        base.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def get(path, params={}, options={})
          headers = options.delete(:headers)
          new(options).get(path, params, headers)
        end

        def post(path, params={}, options={})
          headers = options.delete(:headers)
          new(options).post(path, params, headers)
        end

        def delete(path, params={}, options={})
          headers = options.delete(:headers)
          new(options).delete(path, params, headers)
        end

        def put(path, params={}, options={})
          headers = options.delete(:headers)
          new(options).put(path, params, headers)
        end
      end
      
      module InstanceMethods
        def get(path, params={}, headers={})
          request(:get, path, params, headers)
        end

        def post(path, params={}, headers={})
          request(:post, path, params, headers)
        end

        def put(path, params={}, headers={})
          request(:put, path, params, headers)
        end

        def delete(path, params={}, headers={})
          request(:delete, path, params, headers)
        end
      end
    end
  end
end