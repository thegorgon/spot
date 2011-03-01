class Place < ActiveRecord::Base
  validates :full_name, :presence => true
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  before_validation :clean
  after_create :update_canonical_id
  after_validation :process_external_image
  after_save :process_deduping

  cattr_accessor :per_page
  @@per_page = 15
  
  has_many :wishlist_items, :as => :item
  serialize :image_attribution, Hash
  acts_as_mappable
  
  define_index do
    indexes :clean_name, :sortable => true
    indexes :city
    has "RADIANS(lat)", :as => :latitude, :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float  
    has :wishlist_count
    set_sphinx_primary_key :canonical_id
    set_property :delta => ThinkingSphinx::Deltas::ResqueDelta
  end
  
  has_attached_file :image, 
    :styles           => { :i640x400 => { :geometry => "640x400#", :format => "jpg" }, 
                           :i234x168 => { :geometry => "234x168#", :format => "jpg" },
                           :i117x84 => { :geometry => "117x84#", :format => "jpg" } },
    :default_url      => "/images/defaults/places/:style.png",
    :processing_url   => "/images/defaults/places/:style_processing.png",
    :storage          => :s3,
    :s3_credentials   => "#{Rails.root}/config/apis/s3.yml",
    :path             => "/places/:id/:attachment_:style.:extension",
    :bucket           => S3_BUCKET
  process_attachment_in_background :image, :job => Jobs::PlaceImageProcessor
  
  scope :canonical, where("canonical_id = id")
  scope :with_canonical, joins("INNER JOIN places canonical ON canonical.id = places.canonical_id").select("canonical.*")
  
  def self.filter(params)
    finder = self
    if params[:query]
      finder = finder.search(params[:query], :star => true, :match_mode => :any, :page => params[:page], :per_page => params[:per_page])
    else
      finder = finder.where("image_file_name IS NULL") if params[:filter] == "imageless"
      finder = finder.where("wishlist_count > 0").order("wishlist_count DESC") if params[:filter] == "wishlisted"
      finder = finder.order("id DESC")
      finder = finder.canonical
      finder = finder.paginate(:page => params[:page], :per_page => params[:per_page])
    end
    finder
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
  
  def external_image_url=(value)
    if value.present?
      self.image = nil
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
  
  def google_place
    @google_place ||= GooglePlace.find_by_place_id(id)
  end
  
  def source_place
    if source
      @source_place ||= source.classify.constantize.where(:place_id => id).order("id ASC").first
    end
  end
        
  def reclean!
    clean
    save!
  end
  
  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :name => full_name,
      :address => address_lines,
      :lat => lat.to_f,
      :lng => lng.to_f,
      :id => id,
      :thumbnail_data => image_thumbnail,
      :image_url_640x400 => image.url(:i640x400),
      :image_url_234x168 => image.url(:i234x168),
      :image_url => image.url,
      :updated_at => updated_at
    }
    unless image.file? || options[:default_images]
      hash.merge!(:image_url_640x400 => nil, :image_url_234x168 => nil, :image_url => nil)
    end
    if image_processing? && options[:processed_images]
      hash.merge!(:processed_image_url_640x400 => image.processed_url(:i640x400), :processed_image_url_234x168 => image.processed_url(:i234x168))
    end
    hash
  end

  private
    
  def clean
    self.clean_name = Geo::Cleaner.clean(:name => full_name)
    self.clean_address = Geo::Cleaner.clean(:address => address)
    self.canonical_id = id if id.to_i > 0 && canonical_id.to_i <= 0
  end
  
  def update_canonical_id
    update_attribute(:canonical_id, id) unless canonical_id.to_i > 0
    save
  end
  
  def process_external_image
    if @external_image_url.present?
      self.image_processing = true
      Resque.enqueue(Jobs::PlaceImageProcessor, self.class.name, id, :image, @external_image_url)    
    end
  end
  
  def process_deduping
    if clean_address_changed? || clean_name_changed?
      Resque.enqueue(Jobs::PlaceDeduper, id)
    end
  end
    
end