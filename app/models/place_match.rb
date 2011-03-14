class PlaceMatch
  MAX_GEO_DISTANCE = 50 # 50 Meters is about a third of a block
  MIN_NAME_MATCH = 0.80
  MIN_ADDRESS_MATCH = 0.40
  
  # ===================
  # = SUPPORT STRUCTS =
  # ===================
  
  class Match < Struct.new(:candidate, :proximity); end;

  class Proximity < Struct.new(:name_match, :address_match, :geo_distance)
    def close?
      name_match >= MIN_NAME_MATCH && address_match >= MIN_ADDRESS_MATCH && geo_distance <= MAX_GEO_DISTANCE
    end
    
    def to_i
      name_match + address_match
    end
  end

  # ======================
  # = METHOD DEFINITIONS =
  # ======================

  def self.run(place, sources=nil)
    new(place, sources).run
  end

  def self.proximity(place1, place2)
    clean_name1 = Geo::Cleaner.clean(:name => place1.name, :extraneous => true)
    clean_address1 = Geo::Cleaner.clean(:address => place1.full_address)
    clean_name2 = Geo::Cleaner.clean(:name => place2.name, :extraneous => true)
    clean_address2 = Geo::Cleaner.clean(:address => place2.full_address)
    name_matcher = Amatch::JaroWinkler.new(clean_name1)
    addr_matcher = Amatch::JaroWinkler.new(clean_address1)
    name_match = name_matcher.match(clean_name2)
    addr_match = addr_matcher.match(clean_address2)
    geo_dist = place1.distance_to(place2, :units => :kms) * 1000 # Distance in meters
    Proximity.new(name_match, addr_match, geo_dist)
  end
  
  def initialize(place, sources=nil)
    @place = place
    @query = Geo::Cleaner.clean(:name => @place.name, :extraneous => true)
    @sources = sources
    @sources ||= ExternalPlace.sources
    @sources = [@sources] unless @sources.kind_of?(Array)
  end
  
  def potentials
    unless @potentials.present?
      @potentials = {}
      @sources.each do |src|
        @potentials[src.to_sym] = src.search(:ll => @place, :query => @query) unless @place.external_place(src)
      end
    end
    @potentials
  end
  
  def matches
    unless @matches.present?
      @matches = {}
      potentials.each do |source, places|
        matches = places.collect { |p| Match.new(p, self.class.proximity(@place, p)) }
        matches.sort! { |match1, match2| match2.proximity.to_i <=> match1.proximity.to_i }.first
        @matches[source] = matches
      end
    end
    @matches
  end
  
  def run
    matches.each do |source, matches|
      best = matches.first
      best.candidate.bind_to!(@place) if best.proximity.close?
    end
    true
  end
end