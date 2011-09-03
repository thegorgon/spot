module Wrapr
  class Response
    attr_accessor :status, :raw, :parsed, :error_message, :error_type, :payload
    
    def self.content_type(value)
      @_content_type = value
    end
    
    def self.jsonp_fn(value)
      @_jsonp_fn = value
    end
    
    def parse_response(json)
      self.payload = json
    end
    
    def body=(value)
      self.raw = preparse(value)
      jsonp_fn = self.class.instance_variable_get('@_jsonp_fn')
      self.raw.gsub!(/^#{jsonp_fn}\((.+)\)\;?$/, '\1') if jsonp_fn.present?
      case content_type
      when Mime::JSON, Mime::JS
        self.parsed = JSON.parse(raw) rescue nil
      when Mime::XML
        self.parsed = Nokogiri::XML(raw) rescue nil
      when Mime::URL_ENCODED_FORM
        self.parsed = Rack::Utils.parse_query(raw) rescue nil
      end
      if parsed
        self.status = 200
        parse_response parsed
      else
        self.status = 500
      end
    end
    
    def preparse(body)
      body
    end
    
    def content_type
      @content_type ||= self.class.instance_variable_get('@_content_type')
      @content_type ||= Mime::Type.lookup(headers['Content-Type'].to_s.split(';')[0])
    end
    
    def content_type=(value)
      @content_type = Mime::Type.lookup(value)
    end
    
    def success?
      (status/100.0).floor == 2
    end
    
    def error?
      !success?
    end

    def headers
      @headers ||= {}
    end

    def headers=(value)
      @headers = value
    end
    
    def to_s
      "#<#{self.class} content_type=#{content_type} content_length=#{raw.length} status=#{status}>"
    end
    
    def marshal_dump
      {:headers => headers, :body => raw}
    end
    
    def marshal_load(hash)
      self.headers = hash[:headers]
      self.body = hash[:body]
    end    
  end
end