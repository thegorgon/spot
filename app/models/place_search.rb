class PlaceSearch
  DEFAULT_PAGE_SIZE = 20
  
  def self.perform(params)
    new(params).results
  end
  
  # Accepts any normalizeable LatLng params (e.g. lat and lng, ll, origin)
  # PlaceSearch.new(:q => "query", :r => accuracy, :lat => Lat, :lng => Lng, :page => 2)
  def initialize(params)
    @params = {}
    @params[:query] = (params[:q] || params[:query]).to_s
    @params[:radius] = (params[:r] || params[:radius]).to_f
    @params[:page] = [1, params[:page].to_i].max
    @params[:per_page] = params[:per_page].to_i > 0 ? params[:per_page].to_i : DEFAULT_PAGE_SIZE
    @origin = Geo::LatLng.normalize(params)
    @params[:origin] = @origin
    @results = Set.new
  end
  
  def load
    unless @loaded
      load_local_places
      load_google_places
      @results = @results.to_a
      @loaded = true
    end
  end

  def load_local_places
    local = []
    benchmark = Benchmark.measure do 
      local = Place.search( @params[:query], 
                             :field_weights => { :name => 100, :city => 5, :clean_address => 1 },
                             :page => @params[:page],
                             :per_page => @params[:per_page],
                             :geo => @origin.to_a,
                             :star => true,
                             :match_mode => :any,
                             :order => "@relevance DESC, @geodist ASC" )
    end
    @results |= local
    Rails.logger.info "place-search : Found #{local.length} local places, #{@results.length} total (#{(benchmark.real * 1000).round}ms)"
  end
  
  def results
    load
    @results
  end

  def load_google_places
    google = []
    benchmark = Benchmark.measure do 
      google = GooglePlace.search(@params)
    end
    google.each { |gp| @results.add gp.bind_to_place! }
    Rails.logger.info "place-search : Found #{google.length} google places, #{@results.length} total (#{(benchmark.real * 1000).round}ms)"
  end
  
  def to_json(*args)
    results.collect { |p| p.to_json(*args) }
  end
end