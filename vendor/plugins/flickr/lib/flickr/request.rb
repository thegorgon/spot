module Flickr
  class Request
    ENDPOINT = "http://api.flickr.com/services/rest"
    SSL_ENDPOINT = "https://secure.flickr.com/services/rest"
    
    def self.get(method, params={})
      new(method, params).get
    end
    
    def self.ssl_get(method, params={})
      new(method, params).ssl_get
    end

    def self.post(method, params={})
      new(method, params).post
    end

    def self.ssl_post(method, params={})
      new(method, params).ssl_post
    end
    
    # ====================
    # = Instance Methods =
    # ====================
    
    def initialize(method, params={}, options={})
      @ssl = !!options[:ssl]
      @method = method.gsub(/^flickr\./, '')
      @body = params
    end
    
    def get
      @http_method = :get
      Rails.logger.info "[Flickr] Performing GET request to url : #{url}"
      curl = Curl::Easy.http_get(url)
      body = curl.body_str
      parse(body)
    end
    
    def ssl_get
      @ssl = true
      get
    end
    
    def post
      @http_method = :post
      Rails.logger.info "[Flickr] Performing POST request to url : #{url} with body : #{@body.to_query}"
      curl = Curl::Easy.http_post(url, @body.to_query)
      body = curl.body_str
      parse(body)
    end

    def ssl_post
      @ssl = true
      post
    end
    
    def url
      if @url.blank?
        @url = "#{@ssl ? SSL_ENDPOINT : ENDPOINT}?method=flickr.#{@method}&format=json&api_key=#{Flickr.api_key}"
        @url += "&#{@body.to_query}" if @http_method == :get
      end
      @url
    end
    
    private
    
    def parse(string)
      string.gsub!(/^jsonFlickrApi\((.+)\)\;?$/, '\1')
      response = Response.parse(string)
      Rails.logger.error "[Flickr] Error Response from Flickr API: #{response.inspect}" if response.error?
      response
    end    
  end
end