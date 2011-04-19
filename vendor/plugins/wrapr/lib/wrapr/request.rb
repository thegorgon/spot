module Wrapr
  class Request
    include Options
    include Oauth
    include Cacheing
    include RequestMethods
    attr_reader :options, :input_params, :path
    
    def initialize(options={})
      @options = options
      @cache = options[:cache]
      @cache_expiry = options[:cache_expiry] || 1.day
    end
        
    def request(method, path, params={}, headers={})
      @path = path
      @method = method.to_sym
      @headers = populate_headers(headers)
      @input_params = params 
      @params = populate_params(params)
      @curb = init_curb
      before_send
      @body = @params.to_query if [:put, :post].include?(@method)
      @curb.post_body = @body
      oauthify(@curb)
      load_from_cache if @cache
      if @response
        Rails.logger.info("#{self.class.to_s.underscore} : loaded response from cache #{cache_string}")
      else
        @response = self.class.response_class.new
        @response.content_type = @headers["Accept"] if @headers["Accept"]
        Rails.logger.info("#{self.class.to_s.underscore} : requesting #{@curb.url} with body : #{@curb.post_body}")
        @curb.send("http_#{@method}")
        @response.body = @curb.body_str
        Rails.cache.write(cache_string, {:response => @response, :expires => Time.now + @cache_expiry}, :expires => @cache_expiry) if @cache && @response.success?
      end
      @response
    end
            
    private
            
    def request_url
      request_url = self.class.base_uri.to_s + request_path
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

        @headers.each { |head, value| curb.headers[head] = value }

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