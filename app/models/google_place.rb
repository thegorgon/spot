class GooglePlace < ActiveRecord::Base
  belongs_to :place
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :presence => true
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :presence => true
  validates :cid, :presence => true
  
  # Accepts any normalizeable LatLng params (e.g. lat and lng, ll, origin)
  # GooglePlace.search(:query => "query", :radius => accuracy, :lat => Lat, :lng => Lng, :page => 2, :exclude => "Daves")
  def self.search(params={})
    results = Google::Place.search(params)
    if results.present?
      results.map! { |gp| GooglePlace.from_google(gp) }
      results = results.hash_by { |gp| gp.cid }
      saved = where(:cid => results.keys).includes(:place).all.hash_by { |gp| gp.cid }
      results.keys.each do |cid|
        results[cid] = saved[cid] if saved[cid]
      end
      results.values
    else
      []
    end
  end
  
  def self.from_google(gp)
    object = new
    columns.each do |col|
      if gp.respond_to?(col.name)
        object.send("#{col.name}=", gp.send(col.name))
      end
    end
    object
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