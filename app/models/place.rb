class Place < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  validates :full_name, :presence => true
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  before_validation :clean
  after_create :update_canonical_id
  after_commit :enqueue_image_processing
  after_commit :enqueue_deduping

  cattr_accessor :per_page
  @@per_page = 15
  attr_reader :external_image_url
    
  has_many :wishlist_items, :as => :item, :conditions => { :deleted_at => nil }
  has_many :notes, :class_name => "PlaceNote"
  has_one :business
  serialize :image_attribution, Hash
  acts_as_mappable
  
  define_index do
    indexes :clean_name, :sortable => true
    indexes :city
    indexes :country
    has "RADIANS(lat)", :as => :latitude, :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float  
    has :wishlist_count
    set_property :delta => ThinkingSphinx::Deltas::ResqueDelta
  end
  set_sphinx_primary_key "canonical_id"
  
  has_attached_file :image, 
    :styles           => { :i640x400 => { :geometry => "640x400#", :format => "jpg" }, 
                           :i234x168 => { :geometry => "234x168#", :format => "jpg" },
                           :i117x84 => { :geometry => "117x84#", :format => "jpg" } },
    :default_url      => "/images/defaults/places/:style.png",
    :processing_url   => "/images/defaults/places/:style_processing.png",
    :storage          => :s3,
    :s3_credentials   => "#{Rails.root}/config/apis/s3.yml",
    :path             => "/places/:id/:attachment_:style.:extension",
    :s3_protocol      => "https",
    :bucket           => S3_BUCKET
  process_attachment_in_background :image, :job => Jobs::PlaceImageProcessor
  
  scope :duplicates, where("canonical_id <> id")
  scope :canonical, where("canonical_id = id")
  scope :with_canonical, joins("INNER JOIN places canonical ON canonical.id = places.canonical_id").select("canonical.*")
  scope :with_image, where("image_file_name IS NOT NULL")
  def self.filter(params={})
    finder = self
    if params[:query]
      finder = finder.search(params[:query], :star => true, :match_mode => :any, :page => params[:page], :per_page => params[:per_page])
    else
      finder = finder.where("image_file_name IS NULL") if params[:filter].to_i & 2 > 0 
      finder = finder.where("wishlist_count > 0").order("wishlist_count DESC") if params[:filter].to_i & 1 > 0
      finder = finder.where("image_processing") if params[:filter].to_i & 4 > 0
      finder = finder.order("id DESC")
      finder = finder.canonical
      finder = finder.paginate(:page => params[:page], :per_page => params[:per_page])
    end
    finder
  end
  
  def self.search(*args)
    @sphinx_key_override = :id #Hack, forces the search to think the pk is :id
    search = ThinkingSphinx::Search.new *search_options(args)
    search.send(:populate)
    @sphinx_key_override = nil #Remove Hack
    search
  end
  
  def self.primary_key_for_sphinx
    @sphinx_key_override || :canonical_id
  end
  
  def self.dedupe!
    all.each { |p| DuplicatePlace.dedupe(p) }
  end
  
  def self.reclean!
    all.each { |p| p.reclean! }
  end
  
  def canonical?
    new_record? || canonical_id == id
  end
  
  def duplicate?
    !canonical?
  end
  
  def canonical
    canonical?? self : self.class.find(canonical_id)
  end
  
  def duplicates
    canonical? && !new_record?? self.class.where("canonical_id = #{id} AND id <> #{id}").all : []
  end
  
  def relevance_against(query)
    query = query.split(' ').sort.join(' ')
    city_relevance_doc = Geo::Cleaner.clean(:name => name + ' ' + city).split(' ').sort.join(' ')
    country_relevance_doc = Geo::Cleaner.clean(:name => name + ' ' + country).split(' ').sort.join(' ')
    matcher = (Thread.current[:relevance_matchers] ||= {})[query] ||= Amatch::LongestSubsequence.new(query)
    city_relevance = (100 * matcher.match(city_relevance_doc)/query.length.to_f).round
    country_relevance = (100 * matcher.match(country_relevance_doc)/query.length.to_f).round
    [city_relevance, country_relevance].max
  end
  
  def external_image_url=(value)
    if value.present?
      self.image = nil
      self.image_processing = true
      @external_image_url = value
    end
  end
    
  def image=(file)
    attachment_for(:image).assign(file)
    if file.nil?
      self.image_attribution = self.image_thumbnail = nil
      self.image_processing = false
    end
  end
    
  def name
    full_name
  end
  
  def name=(value)
    self.full_name = value
  end
  
  def name_with_city
    string = name.clone
    string << " in #{city.titlecase}" if city.present?
    string
  end

  def name_with_address_and_city
    string = name.clone
    string << " at #{address_lines[0].titlecase}" if address_lines[0].present? 
    string << " in #{city.titlecase}" if city.present?
  end

  def city_and_region
    [city, region].compact.join(", ")
  end
  
  def share_tweet
    @tweet = "Add #{name}"
    @tweet << " in #{city}" if city
    @tweet << " to your wishlist on Spot"
    @tweet << " ##{city.gsub(' ', '').downcase}" if city
    @tweet << " ##{region_abbr.gsub(' ', '').downcase}" if region
  end
  
  def address_lines
    full_address.to_s.split("\n")
  end
  
  def address_lines=(value)
    value = [value["0"], value["1"]] if value.kind_of?(Hash)
    self.full_address = value.join("\n")
  end
  
  def address
    address_lines.join(', ')
  end
    
  def region_abbr
    inverted = Geo::STATES.invert
    inverted[region.downcase] || region
  end
    
  def external_place(source)
    source = ExternalPlace.lookup(source) unless source.kind_of?(Class)
    (@external_places ||= {})[source.to_sym] ||= source.where(:place_id => id).order("id ASC").first
  end
  
  def external_places
    ExternalPlace.sources.collect { |src| external_place(src) }.compact
  end
        
  def reclean!
    clean
    save!
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :name => full_name,
      :address => address_lines,
      :bitch_dis_where_it_be => {:lines => address_lines, :city => city, :region => region},
      :lat => lat.to_f,
      :lng => lng.to_f,
      :id => id,
      :thumbnail_data => image_thumbnail,
      :image_url_640x400 => image.url(:i640x400),
      :image_url_234x168 => image.url(:i234x168),
      :image_url => image.url,
      :updated_at => updated_at,
      :path => place_path(self),
      :short_url => ShortUrl.shorten(place_path(self))
    }
    if !image.file? && !options[:default_images]
      hash.merge!(:image_url_640x400 => nil, :image_url_234x168 => nil, :image_url => nil)
    end
    hash[:phone_number] = phone_number if phone_number.present?
    if image_processing? && options[:processed_images]
      hash.merge!(:processed_image_url_640x400 => image.processed_url(:i640x400), :processed_image_url_234x168 => image.processed_url(:i234x168))
    end
    # external_places.each do |external|
    #   hash["#{external.class.to_sym}_id"] = external.source_id
    # end
    hash
  end

  private
    
  def clean
    self.clean_name = Geo::Cleaner.clean(:name => full_name)
    self.clean_address = Geo::Cleaner.clean(:address => address)
    self.canonical_id = id if id.to_i > 0 && canonical_id.to_i <= 0
    self.canonical_id = 0 if canonical_id.nil?
  end
  
  def update_canonical_id
    update_attribute(:canonical_id, id) unless canonical_id.to_i > 0
    save
  end
  
  def enqueue_image_processing
    if @external_image_url.present?
      Rails.logger.debug("resque : enqueueing image processing job")
      Resque.enqueue(Jobs::PlaceImageProcessor, self.class.name, id, :image, @external_image_url)    
    end
  end
  
  def enqueue_deduping
    if attribute_commited?(:clean_name) || attribute_commited?(:clean_address)
      Resque.enqueue(Jobs::PlaceDeduper, id)
    end
  end
    
end