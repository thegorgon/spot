module Wrapr
  class Request
    def self.response_class
      to_s.gsub("Request", "Response").constantize
    end

    def self.base_url(ssl=true)
      ""
    end

    def self.get(path, params={}, options={})
      new(options).get(path, params)
    end
    
    def self.post(path, params={}, options={})
      new(options).post(path, params)
    end
    
    def self.delete(path, params={}, options={})
      new(options).delete(path, params)
    end
    
    def self.put(path, params={}, options={})
      new(options).put(path, params)
    end
    
    def self.header(name, value)
      (@_headers ||= {})[name] = value
    end
    
    def self.param(name, value)
      (@_params ||= {})[name] = value
    end
    
    def self.path_param(name, value)
      @_path_param_key = name
      @_path_param_value = value 
    end
        
    def initialize(options={})
      @cache = options[:cache]
      @cache_expiry = options[:cache_expiry] || 1.day
    end
        
    def request(method, path, params={})
      @path = path
      @method = method.to_sym
      @params = populate_params(params)
      @curb = init_curb
      before_send
      @body = @params.to_query if [:put, :post].include?(@method)
      @curb.post_body = @body
      load_from_cache if @cache
      if @response        
        Rails.logger.info("#{self.class.to_s.underscore} : loaded response from cache #{cache_string}")
      else
        @response = self.class.response_class.new
        Rails.logger.info("#{self.class.to_s.underscore} : requesting #{@curb.url} with body : #{@curb.post_body}")
        @curb.send("http_#{@method}")
        @response.body = @curb.body_str
        Rails.cache.write(cache_string, @response, :expires => @cache_expiry) if @cache
      end
      @response
    end
    
    def load_from_cache
      begin
        @response = Rails.cache.read(cache_string)
      rescue ArgumentError => e
        raise unless e.to_s =~ /undefined class/ # unexpected error message, re-raise
        e.to_s.split.last.constantize            # raises NameError if it can't find the constant
        retry
      end
    end
    
    def cache_string
      string = "#{self.class.to_s.underscore}#{request_path}"
      string << (string.index('?') ? "&#{@body}" : "?#{@body}" if @body.present?)
      string
    end
    
    def get(path, params)
      request(:get, path, params)
    end
    
    def post(path, params)
      request(:post, path, params)
    end
    
    def put(path, params)
      request(:put, path, params)
    end
    
    def delete(path, params)
      request(:delete, path, params)
    end
            
    private
    
    def populate_params(input)
      class_params = self.class.instance_variable_get("@_params") || {}
      params = input.clone
      class_params.each do |key, value|
        value = value.call if value.kind_of?(Proc)
        params[key] ||= value
      end
      path_param_key = self.class.instance_variable_get("@_path_param_key")
      path_param_value = self.class.instance_variable_get("@_path_param_value")
      path_param_value = path_param_value.call(@path) if path_param_value.kind_of?(Proc)
      if path_param_key.present?
        @path = ''
        params[path_param_key] ||= path_param_value
      end
      params
    end
        
    def request_url
      request_url = self.class.base_url + request_path
      request_url
    end
    
    def request_path
      if @method == :get && @params.present?
        get_body = @params.to_query
        @path << (@path.index('?') ? "&#{get_body}" : "?#{get_body}")
        @params = {}
      end
      @path
    end
    
    def before_send
      # hook for customization
    end
    
    def init_curb
      Curl::Easy.new(request_url) do |curb|
        curb.useragent = "Spot App Server"
        
        headers = self.class.instance_variable_get("@_headers") || {}
        headers.each do |head, value|
          value = value.call if value.kind_of?(Proc)
          curb.headers[head] = value
        end

        curb.on_header do |header_data|
          key, value = header_data.split(':')
          key.strip!
          @response.headers[key] = value.strip if value
          header_data.length
        end
      end
    end
  end
end