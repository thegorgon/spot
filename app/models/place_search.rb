class PlaceSearch < ActiveRecord::Base
  attr_reader :benchmarks, :cleanq
  attr_accessor :page, :per_page
  DEFAULT_PAGE_SIZE = 10
  validates :query, :presence => true, :length => {:minimum => 0}
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :if => :lng?
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :if => :lat?
  belongs_to :result, :class_name => "Place"
      
  class Result
    attr_reader :place, :distance, :relevance, :source
    delegate :image, :lat, :lng, :address_lines, :full_address, :wishlist_count, :name, :image_thumbnail, :to_lat_lng, :to => :place
    
    def initialize(params={})
      @place = params[:place]
      @position = params[:position]
      @query = params[:query]
      @distance = @place.distance_to(@position) if @position
      @relevance = @place.relevance_against(@query)
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
  
  def self.from_params(params)
    object = new
    params[:query] ||= params[:q] if params[:q]
    params[:position] ||= params[:geo_position] if params[:geo_position]
    params[:position] ||= Geo::Position.normalize(:ll => params[:ll]) if params[:ll]
    params[:page] = [1, params[:page].to_i].max
    params[:per_page] = params[:per_page].to_i > 0 ? params[:per_page].to_i : DEFAULT_PAGE_SIZE
    params.each do |param, value|
      object.send("#{param}=", value) if object.respond_to?("#{param}=")
    end
    object
  end
  
  def self.from_params!(params)
    object = from_params(params)
    object.save!
    object
  end
  
  def position=(value)
    @position = value.kind_of?(Geo::Position) ? value : Geo::Position.from_http_header(value)
    self.lat = @position.try(:lat)
    self.lng = @position.try(:lng)
    self[:position] = @position.try(:to_http_header)
  end
  
  def position
    @position ||= Geo::Position.new(lat, lng)
  end
  
  def query=(value)
    self[:query] = value
    @cleanq = Geo::Cleaner.clean(:name => value)
  end
  
  def results
    load
    @results.to_a
  end
  
  def as_json(*args)
    results.as_json(*args)
  end
    
  private
  
  def load
    if !@loaded && query.present?
      @benchmarks = {}
      @benchmarks[:total] = Benchmark.measure do 
        @results = {}
        load_local_places
        load_google_places if @position
        @results = @results.values.sort do |r1, r2| 
          if r2.relevance == r1.relevance && r1.wishlist_count == r2.wishlist_count 
            r1.distance <=> r2.distance
          elsif r2.relevance == r1.relevance
            r2.wishlist_count <=> r1.wishlist_count
          else
            r2.relevance <=> r1.relevance
          end
        end
        @loaded = true
      end
    end
  end
  
  def load_local_places
    local = []
    @benchmarks[:local] = Benchmark.measure do 
      options = {:page => page, :per_page => per_page}
      options[:order] = "@relevance DESC, wishlist_count DESC"
      options[:field_weights] = {:clean_name => 5, :city => 2, :country => 1}
      if @position
        options[:geo] = @position.ts_geo
        options[:order] << ", @geodist ASC"
      end
      options.merge!(:match_mode => :any)
      local = Place.search(@cleanq, options).compact
    end
    local.each do |lp|
      @results[lp.canonical_id] ||= Result.new(:place => lp, :position => @position, :query => @cleanq, :source => "local")
    end
    Rails.logger.info "place-search : Querying #{@cleanq}, found #{local.length} local places, #{@results.length} total (#{(benchmarks[:local].real * 1000).round}ms)"
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
end