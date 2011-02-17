class Place < ActiveRecord::Base
  validates :full_name, :presence => true
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  before_validation :clean
  after_validation :download_external_image
  cattr_accessor :per_page
  @@per_page = 15
  attr_writer :external_image_url
  serialize :image_attribution, Hash
  acts_as_mappable
  
  define_index do
    indexes :clean_name, :sortable => true
    indexes :clean_address
    indexes :city
    indexes :region
    has "RADIANS(lat)", :as => :latitude, :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float  
    has :wishlist_count
  end
  
  has_attached_file :image, 
    :styles           => { :i640x400 => { :geometry => "640x400#", :format => "jpg" }, 
                           :i234x168 => { :geometry => "234x168#", :format => "jpg" },
                           :i117x84 => { :geometry => "117x84#", :format => "jpg" } },
    :default_url      => "/images/defaults/places/:style.png",
    :storage          => :s3,
    :s3_credentials   => "#{Rails.root}/config/apis/s3.yml",
    :path             => "/places/:id/:attachment_:style.:extension",
    :bucket           => S3_BUCKET
      
  def self.filter(params)
    finder = self
    finder = finder.where("image_file_name IS NULL") if params[:filter] == "imageless"
    finder = finder.where("wishlist_count > 0") if params[:filter] == "wishlisted"
    finder = finder.where("full_name LIKE ?", "%#{params[:query]}%") if params[:query]
    finder = finder.order("id DESC")
    finder
  end

  def document
    "#{clean_name} : #{clean_address}"
  end
  
  def name
    full_name
  end
  
  def address_lines
    full_address.to_s.split("\n")
  end
  
  def address_lines=(value)
    self.full_address = "#{value["0"]}\n#{value["1"]}"
  end
  
  def address
    full_address
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
      :image_url_640x400 => image.file?? image.url(:i640x400) : nil,
      :image_url_234x168 => image.file?? image.url(:i234x168) : nil,
      :image_url => image.file?? image.url : nil
    }
    hash
  end

  def image=(file)
    attachment_for(:image).assign(file)
    if file.nil?
      self.image_attribution = self.image_thumbnail = nil
    else
      file = attachment_for(:image).to_tempfile(file)
      lq_thumb = Paperclip.processor(:thumbnail).make(file, {:geometry => "117x84#", :convert_options => '-quality 10 -strip -colorspace RGB -resample 72', :format => 'jp2'}, self)
      self.image_thumbnail = ActiveSupport::Base64.encode64(lq_thumb.to_a.join)
    end
  end

  private
    
  def clean
    self.clean_name = Geo::Cleaner.clean(:name => full_name)
    self.clean_address = Geo::Cleaner.clean(:address => full_address)
  end
    
  def download_external_image
    if @external_image_url.present?
      begin
        io = open(URI.parse(@external_image_url))
        def io.original_filename; base_uri.path.split('/').last; end
        self.image = io.original_filename.blank?? nil : io
      rescue => e
        Rails.logger.error "Error Downloading Place File : #{e.message}"
      end
    end
  end
  
end