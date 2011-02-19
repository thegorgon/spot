class WishlistItem < ActiveRecord::Base
  ITEM_TYPES = ["Place"]
  belongs_to :user
  belongs_to :item, :polymorphic => true, :counter_cache => :wishlist_count
  validates :user_id, :presence => true, :numericality => true
  validates :item_type, :presence => true, :inclusion => ITEM_TYPES
  validates :item_id, :presence => true, :numericality => true
  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :if => :lat?
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :if => :lng
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :_class => self.class.to_s,
      :id => id,
      :item => item.as_json(args),
      :created_at => created_at
    }
  end
  
  def location=(value)
    if value = Geo::Position.from_http_header(value)
      self.lat = value.lat
      self.lng = value.lng
    end
  end
end