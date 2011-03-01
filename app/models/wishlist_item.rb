class WishlistItem < ActiveRecord::Base
  ITEM_TYPES = ["Place"]
  
  belongs_to :user
  belongs_to :item, :polymorphic => true, :counter_cache => :wishlist_count
  
  validates :user_id, :presence => true, :numericality => true
  validates :item_type, :presence => true, :inclusion => ITEM_TYPES
  validates :item_id, :presence => true, :numericality => true  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :if => :lat?
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :if => :lng
  
  after_create :attribute_result_to_search
  attr_writer :search_id
  cattr_accessor :per_page
  @@per_page = 20
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :item => item.as_json(args),
      :created_at => created_at
    }
  end
  
  def self.activity(params={})
    params = params.symbolize_keys
    origin = Geo::LatLng.normalize(params)
    radius = params[:radius] || 50
    params[:page] = [1, params[:page].to_i].max
    finder = where(:item_type => "Place").joins("INNER JOIN places ON places.id = wishlist_items.item_id")
    finder = finder.where("#{Place.distance_sql(origin)} <= #{radius}") if origin
    finder = finder.order("id DESC")
    finder.paginate(params.slice(:page, :per_page))
  end
  
  def location=(value)
    if value = Geo::Position.from_http_header(value)
      self.lat = value.lat
      self.lng = value.lng
    end
  end
  
  def attribute_result_to_search
    PlaceSearch.where(:id => @search_id).update_all(:result_id => item_id) if @search_id.to_i > 0
  end
end