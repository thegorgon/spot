class PlaceSearch
  attr_reader :benchmarks
  DEFAULT_PAGE_SIZE = 20
  
  def self.perform(params)
    new(params).results
  end
  
  class Result
    attr_reader :place, :distance, :relevance, :source
    delegate :image, :lat, :lng, :address_lines, :full_address, :wishlist_count, :name, :image_thumbnail, :to_lat_lng, :to => :place
    
    def initialize(params={})
      @place = params[:place]
      @position = params[:position]
      @distance = @place.distance_to(@position) if @position
      @relevance = params[:relevance]
      @source = params[:source]
    end
    
    def as_json(*args)
      hash = @place.as_json(*args)
      hash[:distance] = @distance
      hash[:relevance] = @relevance
      hash
    end
    
    def place_id
      @place.try(:id)
    end
  end
  
  # Accepts any normalizeable LatLng params (e.g. lat and lng, ll, position)
  # PlaceSearch.new(:q => "query", :r => accuracy, :lat => Lat, :lng => Lng, :page => 2)
  def initialize(params={})
    @params = {}
    @params[:query] = (params[:q] || params[:query]).to_s
    @params[:radius] = (params[:r] || params[:radius]).to_f
    @params[:page] = [1, params[:page].to_i].max
    @params[:per_page] = params[:per_page].to_i > 0 ? params[:per_page].to_i : DEFAULT_PAGE_SIZE
    @query = Geo::Cleaner.clean(:name => @params[:query], :extraneous => true)
    @matcher = Amatch::Sellers.new(@query)
    @position = Geo::Position.normalize(params)
  end
  
  def load
    if !@loaded && @params[:query].present?
      @benchmarks = {}
      @benchmarks[:total] = Benchmark.measure do 
        @results = {}
        load_local_places
        load_google_places if @position
        @results = @results.values.sort { |r1, r2| r2.relevance == r1.relevance ? r1.distance <=> r2.distance : r1.relevance <=> r2.relevance }
        @loaded = true
      end
    end
  end
  
  def query
    @params[:query].to_s
  end

  def ll
    @position.to_s
  end
  
  def position
    @position || Geo::Position.new(0, 0)
  end
  
  def result_count
    results.count
  end

  def load_local_places
    local = []
    @benchmarks[:local] = Benchmark.measure do 
      options = @params.slice(:page, :per_page)
      options[:order] = "@relevance DESC"
      if @position
        options[:geo] = @position.ts_geo
        options[:order] << ", @geodist ASC"
      end
      options.merge!(:match_mode => :any)
      local = Place.search(@query, options)
    end
    local.each_with_match do |lp, match|
      cleaned = Geo::Cleaner.clean(:name => lp.clean_name, :extraneous => true)
      @results[lp.canonical_id] ||= Result.new(:place => lp, :relevance => @matcher.match(cleaned), :position => @position, :source => "local")
    end
    Rails.logger.info "place-search : Querying #{@query}, found #{local.length} local places, #{@results.length} total (#{(benchmarks[:local].real * 1000).round}ms)"
  end
  
  def results
    load
    @results.to_a
  end

  def load_google_places
    google = []
    @benchmarks[:google_load] = Benchmark.measure do 
      google = GooglePlace.search(@params.merge(:origin => @position))
    end
    @benchmarks[:google_bind] = Benchmark.measure do
      google.each do |gp|
        Rails.logger.info "place-search : Found google place : #{gp.name}"
        gp.bind_to_place!
        cleaned = Geo::Cleaner.clean(:name => gp.place.clean_name, :extraneous => true)
        @results[gp.place.canonical_id] ||= Result.new(:place => gp.place, :relevance => @matcher.match(cleaned), :position => @position, :source => "google")
      end
    end
    Rails.logger.info "place-search : Found #{google.length} google places, #{@results.length} total (#{(benchmarks[:google_load].real * 1000).round}ms)"
  end
  
  def to_json(*args)
    results.collect { |p| p.to_json(*args) }
  end
end