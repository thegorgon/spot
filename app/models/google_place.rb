class GooglePlace < ActiveRecord::Base
  belongs_to :place
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :presence => true
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :presence => true
  validates :cid, :presence => true
  
  # Accepts any normalizeable LatLng params (e.g. lat and lng, ll, origin)
  # GooglePlace.search(:query => "query", :radius => accuracy, :lat => Lat, :lng => Lng, :page => 2, :exclude => "Daves")
  def self.search(*args)
    request = Curl::Easy.perform(search_url(*args))
    json = JSON.parse(request.body_str) rescue nil
    if json && json["responseData"] && json["responseData"]["results"]
      results = json["responseData"]["results"]
      results.map! { |r| parse(r) }
      results.compact!
      results = results.hash_by { |gp| gp.cid }
      saved = where(:cid => results.keys).includes(:place).all.hash_by { |gp| gp.cid }
      results.keys.each do |cid|
        results[cid] = saved[cid] if saved[cid]
      end
      results.values
    else
      raise ExternalServiceError, "Invalid results from google place search"
    end
  end
  
  def self.search_url(*args)
    origin = Geo::LatLng.normalize(*args)
    raise ArgumentError, "Invalid GooglePlace search: Please provide a normalizeable LatLng in your arguments" unless origin
    options = args.extract_options!
    page =  options[:page].blank? ? 1 : options[:page] * 8
    if !options[:query].blank?
      query = options[:query]
    elsif options[:exclude] && options[:query]
      query = "#{options[:query]} #{options[:exclude].collect{ |place| '-"' + place.name + '"' }.join(" ")}"
    else
      query = "*"
    end
    url = "http://ajax.googleapis.com/ajax/services/search/local?v=1.0&q=#{CGI.escape(query)}&rsz=large&start=#{page}&sll=#{origin.ll}"
    Rails.logger.info("google-search: #{url}")
    url
  end
    
  def self.parse(result)
    place = new
    if result && result.kind_of?(Hash) && result['url'].present? && (cid = result['url'].gsub(/.*cid=(.*)$/, '\1')) && cid.to_i > 0
      place.cid = cid.to_i.to_s
      place.name = result['titleNoFormatting']
      place.street_address = result['streetAddress'] 
      place.listing_type = result['listingType']
      place.city = result['city']
      place.region = result['region']
      place.country = result['country']
      place.address = result['addressLines'] && result['addressLines'].join("\n")
      place.phone_number = result['phoneNumbers'] && result['phoneNumbers'].first.kind_of?(Hash) ? result['phoneNumbers'].first['number'] : nil
      place.lat = result['lat'].to_f
      place.lng = result['lng'].to_f
      place
    else
      nil
    end
  end
  
  def place
    @place ||= Place.canonical.find(place_id) if place_id
  end
    
  def bind_to_place!
    if place_id && place
      place.canonical
    else
      new_place = to_place
      new_place.save
      self.place = new_place
    end
    if place_id && changed?
      save!
    end
    place
  end
  
  def to_place
    p = Place.new
    [:lat, :lng, :city, :region, :country, :phone_number].each do |k|
      p.send("#{k}=", send(k))
    end
    p.full_address = address
    p.full_name = name
    p.source = "GooglePlace"
    p
  end  
end