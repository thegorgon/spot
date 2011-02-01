class Place < ActiveRecord::Base
  validates :full_name, :presence => true
  before_validation :clean, :on => :create
  cattr_accessor :per_page
  @@per_page = 15
  acts_as_mappable
  has_attached_file :image, 
    :styles => { :i640x400 => "640x400#", :i234x168 => "234x168#", :i117x84 => "117x84#" }, 
    :default_url => "/images/defaults/places/:style.png",
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :bucket         => S3_BUCKET
  
  def self.search(params)
    google = GooglePlace.search(params)
    places = google.collect do |gp|
      gp.bind_to_place!
    end
    places
  end

  def to_loc
    Geo::Loc.new( :lat => lat, 
                  :lng => lng, 
                  :full_address => address )
  end
  
  def document
    "#{clean_name} : #{clean_address}"
  end
  
  def source_place
    if source
      source.classify.constantize.where(:place_id => id).order("id ASC").first
    end
  end
  
  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_class => self.class.to_s,
      :name => full_name,
      :address => full_address,
      :id => id,
      :thumbnail_data => image_thumbnail,
      :image_url_640x400 => image.file?? image.url(:i640x400) : nil,
      :image_url_234x168 => image.file?? image.url(:i234x168) : nil
    }
  end

  private
  
  def clean
    self.clean_name = Geo::Cleaner.clean(:name => full_name)
    self.clean_address = Geo::Cleaner.clean(:address => full_address)
  end
  
end