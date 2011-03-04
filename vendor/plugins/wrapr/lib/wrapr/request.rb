module Wrapr
  class Request
    def self.response_class
      Wrapr::Response
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
    
    def initialize(options={})
      @cache = options[:cache]
      @cache_expiry = options[:cache_expiry] || 1.day
    end
        
    def request(method, path, params={})
      @path = path
      @method = method.to_sym
      @params = sanitize params
      @body = @params.to_query if @method != :get      
      load_from_cache if @cache
      if @response        
        Rails.logger.info("#{self.class.to_s.underscore} : loaded response from cache #{cache_string}")
      else
        @response = self.class.response_class.new
        Rails.logger.info("#{self.class.to_s.underscore} : requesting #{curb.url} with body : #{curb.post_body}")
        curb.send("http_#{@method}")
        @response.body = curb.body_str
        @curb = nil
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
    
    def sanitize(params)
      sanitized = {}
      params.each do |k, v|
        sanitized[k] = v unless v.blank?
      end
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
    
    def curb
      unless @curb
        @curb = Curl::Easy.new(request_url) do |curb|
          curb.on_header do |header_data|
            key, value = header_data.split(':')
            key.strip!
            @response.headers[key] = value.strip if value
            header_data.length
          end
        end
        @curb.post_body = @body
      end
      @curb
    end
  end
end