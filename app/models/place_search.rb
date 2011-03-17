class PlaceSearch < ActiveRecord::Base
  attr_writer :utf8, :action, :controller, :format
  attr_reader :benchmarks, :cleanq
  DEFAULT_PAGE_SIZE = 10
  validates :query, :presence => true, :length => {:minimum => 0}
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  belongs_to :result, :class_name => "Place"
      
  class Result
    attr_reader :place, :distance, :relevance, :source
    delegate :image, :lat, :lng, :address_lines, :full_address, :wishlist_count, :name, :image_thumbnail, :to_lat_lng, :to => :place
    
    def initialize(params={})
      @place = params[:place]
      @position = params[:position]
      @query = params[:query]
      @distance = @place.distance_to(@position) if @position
      @relevance = @place.relevance_against(@query, @position)
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
  
  def page=(value)
    @page = value.to_i
  end
  
  def page
    [1, @page.to_i].max
  end
  
  def per_page=(value)
    @per_page = value.to_i
  end
  
  def per_page
    @per_page.to_i > 0 ? @per_page.to_i : DEFAULT_PAGE_SIZE
  end
  
  def ll=(value)
    self.position = Geo::Position.normalize(:ll => value)
  end
  
  def position=(value)
    @position = value.kind_of?(Geo::Position) ? value : Geo::Position.from_http_header(value)
    self.lat = @position.lat
    self.lng = @position.lng
    self[:position] = @position.try(:to_http_header)
  end
  alias_method :geo_position=, :position=
  
  def position
    @position ||= Geo::Position.from_http_header(value)
  end
  
  def query=(value)
    @query = self[:query] = value
    @cleanq = Geo::Cleaner.clean(:name => value)
  end
  alias_method :q=, :query=
  
  def load
    if !@loaded && @query.present?
      @benchmarks = {}
      @benchmarks[:total] = Benchmark.measure do 
        @results = {}
        load_local_places
        load_google_places if @position
        @results = @results.values.sort { |r1, r2| r2.relevance == r1.relevance ? r1.distance <=> r2.distance : r2.relevance <=> r1.relevance }
        @loaded = true
      end
    end
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
      options = {:page => page, :per_page => per_page}
      options[:order] = "@relevance DESC"
      if @position
        options[:geo] = @position.ts_geo
        options[:order] << ", @geodist ASC"
      end
      options.merge!(:match_mode => :any)
      local = Place.search(@cleanq, options)
    end
    local.each_with_match do |lp, match|
      @results[lp.canonical_id] ||= Result.new(:place => lp, :position => @position, :query => @cleanq, :source => "local")
    end
    Rails.logger.info "place-search : Querying #{@cleanq}, found #{local.length} local places, #{@results.length} total (#{(benchmarks[:local].real * 1000).round}ms)"
  end
  
  def results
    load
    @results.to_a
  end

  def load_google_places
    google = []
    @benchmarks[:google_load] = Benchmark.measure do 
      google = ExternalPlace::GooglePlace.search(:query => query, :page => page, :per_page => per_page, :geo_position => position)
    end
    @benchmarks[:google_bind] = Benchmark.measure do
      google.each do |gp|
        Rails.logger.info "place-search : Found google place : #{gp.name}"
        gp.bind_to_place!
        @results[gp.place.canonical_id] ||= Result.new(:place => gp.place, :position => @position, :query => @cleanq, :source => "google")
      end
    end
    Rails.logger.info "place-search : Found #{google.length} google places, #{@results.length} total (#{(benchmarks[:google_load].real * 1000).round}ms)"
  end
  
  def to_json(*args)
    results.to_json(*args)
  end
end