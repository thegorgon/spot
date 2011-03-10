class PlaceMatch
  MAX_GEO_DISTANCE = 50 # 50 Meters is about a third of a block
  MIN_NAME_MATCH = 0.80
  MIN_ADDRESS_MATCH = 0.70
  
  def self.run(place, sources=nil)
    new(place, sources).run
  end
  
  class Distance < Struct.new(:name_distance, :address_distance, :geo_distance)
    def close?
      name_distance >= MIN_NAME_MATCH && address_distance >= MIN_ADDRESS_MATCH && geo_distance <= MAX_GEO_DISTANCE
    end
    
    def to_i
      name_distance + address_distance
    end
  end

  def self.distance_between(place1, place2)
    clean_name1 = Geo::Cleaner.clean(:name => place1.name, :extraneous => true)
    clean_address1 = Geo::Cleaner.clean(:address => place1.full_address)
    clean_name2 = Geo::Cleaner.clean(:name => place2.name, :extraneous => true)
    clean_address2 = Geo::Cleaner.clean(:address => place2.full_address)
    name_matcher = Amatch::JaroWinkler.new(clean_name1)
    addr_matcher = Amatch::JaroWinkler.new(clean_address1)
    name_dist = name_matcher.match(clean_name2)
    addr_dist = addr_matcher.match(clean_address2)
    geo_dist = place1.distance_to(place2, :units => :kms) * 1000 # Distance in meters
    # norm_addr_dist = 2.0 * addr_dist/(clean_address1.length + clean_address2.length)
    # norm_name_dist = 2.0 * name_dist/(clean_name1.length + clean_name2.length)
    Distance.new(name_dist, addr_dist, geo_dist)
  end
  
  def initialize(place, sources=nil)
    @place = place
    @query = Geo::Cleaner.clean(:name => @place.name, :extraneous => true)
    @sources ||= ExternalPlace.sources
    @sources = [@sources] unless @sources.kind_of?(Array)
  end
  
  def potentials
    if @potentials
      @potentials
    else
      @potentials = {}
      @sources.each do |src|
        @potentials[src.to_sym] = src.search(:ll => @place, :query => @query) unless @place.external_place(src)
      end
      @potentials
    end
  end
  
  def run
    potentials.each do |source, places|
      matches = places.collect { |p| {:distance => self.class.distance_between(@place, p), :candidate => p } }
      matches.sort! { |match1, match2| match1[:distance].to_i <=> match2[:distance].to_i }.first
      best = matches.first
      if best[:distance].close?
        best[:candidate].bind_to!(@place)
      end
    end
    true
  end
end