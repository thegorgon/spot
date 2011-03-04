module Wrapr
  class Response
    attr_accessor :status, :raw, :parsed, :error_message

    def body=(value)
      self.raw = preparse(value)
      case content_type
      when Mime::JSON
        self.parsed = JSON.parse(raw) rescue nil
      when Mime::XML
        self.parsed = Nokogiri::XML(raw) rescue nil
      end
      if parsed
        parse_response parsed
        self.status = 200
      else
        self.status = 500
      end
    end
    
    def preparse(body)
      body
    end
    
    def content_type
      @content_type ||= Mime::Type.lookup(headers['Content-Type'].split(';')[0])
    end
    
    def success?
      (status/100.0).floor == 2
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