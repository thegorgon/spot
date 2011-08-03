class ActivityItem < ActiveRecord::Base
  ACTIONS = ["CREATE", "DELETE"]
  WISHLIST_ONLY_REVISION = 72
  belongs_to :actor, :class_name => "User"
  belongs_to :activity, :polymorphic => true
  belongs_to :item, :polymorphic => true
  #TODO Remove source fields
  belongs_to :source, :polymorphic => true
  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  validates :action, :inclusion => ACTIONS, :presence => true

  scope :since, lambda { |date| where(["created_at > ?", date]) }
  scope :until, lambda { |date| where(["created_at <= ?", date]) }

  acts_as_mappable
  
  def self.feed(params={})
    params = params.symbolize_keys
    origin = Geo::Position.normalize(params)
    radius = params[:radius]
    params[:device] ||= {}
    params[:page] = [1, params[:page].to_i].max
    finder = self
    finder = finder.within(radius, :origin => origin) if radius && origin
    finder = finder.where(:action => "CREATE")
    finder = finder.where(:activity_type => "WishlistItem") if params[:device][:app_version].to_i < WISHLIST_ONLY_REVISION
    finder = finder.since(params[:since]) if params[:since]
    finder = finder.until(params[:until]) if params[:until]
    finder = finder.order("activity_items.created_at DESC")
    records = finder.paginate(:page => params[:page], :per_page => params[:per_page], :include => [:actor, :activity, :item])
    records
  end  
    
  def action=(value)
    if value.respond_to?(:upcase)
      self[:action] = value.upcase 
    else
      self[:action] = value
    end
  end
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :activity => activity.as_json(args),
      :item => item.as_json(args),
      :user => actor.as_json(args),
      :created_at => created_at,
    }
  end
  
end