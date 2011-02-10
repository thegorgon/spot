module Google
  class Image
    ENDPOINT = "https://ajax.googleapis.com/ajax/services/search/images"
    REFERRER = Rails.env.production?? "www.spot-app.com" : "www.rails.local:3000"
    INSTANCE_KEYS = [:height, :width, :id, :tb_width, :tb_height, :url, :tb_url]
    attr_accessor *INSTANCE_KEYS
    attr_accessor :id, :context
    
    def self.search(params={})
      params[:q] = params[:q] || params.delete(:query)
      json = json(params)
      status = json["responseStatus"].to_i rescue -1
      parsed = []
      if status == 200
        results = json["responseData"]["results"]
        parsed = results.collect { |r| parse(r) }
        parsed.compact!
      end
      parsed
    end
    
    def self.parse(json)
      if json && json.kind_of?(Hash)
        object = new
        INSTANCE_KEYS.each do |key|
          object.send("#{key}=", json[key.to_s.camelcase(:lower)])
        end
        object.id = json["imageId"]
        object.context = json["originalContextUrl"]
        object
      else
        nil
      end
    end
    
    def self.json(params={})
      JSON.parse(raw(params)) rescue nil
    end
    
    def self.raw(params={})
      fetch_url = url(params)
      Rails.logger.info "[Google Photo] Performing GET request to url : #{fetch_url}"
      curl = Curl::Easy.http_get(fetch_url) do |curl|
        curl.headers["Referer"] = "http://#{REFERRER}"
      end
      curl.body_str
    end
    
    def self.url(params={})
      url = "#{ENDPOINT}"
      params[:key] = Google.api_key(REFERRER)
      params[:v] ||= "1.0"
      url += "?#{params.to_query}" if params.keys.length > 0
      url
    end
    
    def source
      'google'
    end
    
    def owner_url
      context
    end
    
    def url(params={})
      @url
    end
  end
end