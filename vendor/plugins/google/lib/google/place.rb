module Google
  class Place
    ENDPOINT = "http://ajax.googleapis.com/ajax/services/search/local"
    REFERRER = Rails.env.production?? "www.spotmembers.com" : "www.rails.local:3000"
    attr_accessor :cit, :name, :street_address, :listing_type, :city, :region, :country, :address_lines, :phone_number, :lat, :lng
    attr_accessor :cid
    
    def self.search(params={}, options={})
      json = json(params)
      status = json["responseStatus"].to_i rescue -1
      parsed = []
      if status == 200
        results = json["responseData"]["results"]
        parsed = results.map { |r| parse(r) }
        parsed.compact!
      end
      parsed
    end
    
    def self.parse(json)
      if json && json.kind_of?(Hash) && json['url'].present? && (cid = json['url'].gsub(/.*cid=(.*)$/, '\1')) && cid.to_i > 0
        object = new
        object.cid = cid.to_i.to_s
        object.name = json['titleNoFormatting']
        object.street_address = json['streetAddress'] 
        object.listing_type = json['listingType']
        object.city = json['city']
        object.region = json['region']
        object.country = json['country']
        object.address_lines = json['addressLines']
        object.phone_number = json['phoneNumbers'] && json['phoneNumbers'].first.kind_of?(Hash) ? json['phoneNumbers'].first['number'] : nil
        object.lat = json['lat'].to_f
        object.lng = json['lng'].to_f
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
      Rails.logger.info "google-photo : performing GET request to url : #{fetch_url}"
      curl = Curl::Easy.http_get(fetch_url) do |curl|
        curl.headers["Referer"] = "http://#{REFERRER}"
      end
      curl.body_str
    end
    
    def self.url(options={})
      origin = Geo::LatLng.normalize(options)
      raise ArgumentError, "Invalid GooglePlace search: Please provide a normalizeable LatLng in your arguments" unless origin
      page =  options[:page].blank?? 1 : options[:page]
      start = 8 * (page - 1)
      query = options[:q] || options[:query]
      if options[:exclude] && query.present?
        query = "#{options[:q]} #{options[:exclude].collect{ |place| '-"' + place.name + '"' }.join(" ")}"
      elsif query.blank?
        query = "*"
      end
      url = "#{ENDPOINT}"
      params = {}
      params[:v] ||= "1.0"
      params[:q] = CGI.escape(query)
      params[:rsz] = :large
      params[:start] = start
      params[:sll] = origin.ll
      url += "?#{params.to_query}" if params.keys.length > 0
      Rails.logger.info("google-search: #{url}")
      url
    end
    
  end
end